###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class DeidentifiedClientsXlsx < ApplicationRecord
  mount_uploader :file, DeidentifiedClientsXlsxFileUploader
  attr_accessor :agency_id, :update_availability
  attr_reader :added, :touched, :problems, :clients

  def agency_options_for_select
    Agency.order(name: :asc).pluck(:name, :id).to_h
  end

  def valid_header?
    parse_xlsx unless @xlsx

    # Assume data is on default sheet, and header starts at A1
    @xlsx.row(1).map(&:strip).map(&:downcase) == self.class.file_header.map(&:strip).map(&:downcase)
  end

  def import(agency, update_availability: false)
    @added = 0
    @touched = 0
    @clients = []
    @update_availability = update_availability

    return unless valid_header?

    DeidentifiedClient.where(agency: agency).update_all(available: false) if @update_availability

    @xlsx.each_with_index do |raw, index|
      next if skip?(raw, index)

      row = Hash[file_attributes.keys.zip(raw)]
      client = DeidentifiedClient.where(agency: agency, client_identifier: row[:client_identifier]).first_or_initialize
      @clients << client
      cleaned = begin
        clean_row(client, row)
      rescue StandardError
        next
      end

      cleaned[:agency_id] = agency&.id
      cleaned[:identified] = false # mark as de-identified client
      if @update_availability
        cleaned[:available] = true
        cleaned[:actively_homeless] = true
      end

      @added += 1 if client.updated_at.nil?
      @touched += 1 if client.updated_at.present?
      client.update(cleaned)

      assessment = client.current_assessment
      assessment.actively_homeless = true if @update_availability
      assessment_type = Config.get(:deidentified_client_assessment) || 'DeidentifiedClientAssessment'
      assessment = build_assessment(client, agency, assessment_type) if assessment.nil? || assessment.class.name != assessment_type
      # maintain current active status
      client.actively_homeless = assessment.actively_homeless
      assessment = client.update_assessment_from_client(assessment)
      assessment.save(validate: false) # We don't have the CE Event required fields
    end
  end

  def build_assessment(client, agency, assessment_type)
    assessment_type.constantize.new(assessment_type: assessment_type, agency_id: agency.id, non_hmis_client_id: client.id)
  end

  # Ignore the header, and empty rows
  def skip?(row, index)
    index.zero? || row[2].blank?
  end

  def clean_row(client, row)
    result = row.dup

    result[:neighborhood_interests] = convert_to_neighborhood_interests(client, :shelter_location, row[:shelter_location])
    result.delete(:shelter_location)
    result[:disabling_condition] = yes_no_to_bool(client, :disabling_condition, row[:disabling_condition])
    # :client_identifier
    result[:substance_abuse_problem] = yes_no_to_bool(client, :substance_abuse_problem, row[:substance_abuse_problem])
    result[:mental_health_problem] = yes_no_to_bool(client, :mental_health_problem, row[:mental_health_problem])
    result.delete(:occurrences_of_homelessness)
    result[:days_homeless] = convert_to_number(client, :days_homeless, row[:days_homeless])
    result[:family_member] = yes_no_to_bool(client, :family_member, row[:family_member])
    result[:sixty_plus] = yes_no_to_bool(client, :sixty_plus, row[:sixty_plus])
    result[:is_currently_youth] = yes_no_to_bool(client, :is_currently_youth, row[:is_currently_youth])
    result[:calculated_chronic_homelessness] = yes_no_to_bool(client, :chronic_homeless, row[:chronic_homeless]) ? 1 : 0
    result.delete(:chronic_homeless)
    result[:pregnancy_status] = yes_no_to_bool(client, :pregnancy_status, row[:pregnancy_status])
    result[:pregnant_under_28_weeks] = result[:pregnancy_status]
    result[:veteran] = yes_no_to_bool(client, :veteran, row[:veteran])
    result[:hiv_aids] = yes_no_to_bool(client, :hiv_aids, row[:hiv_aids])
    result[:health_prioritized] = yes_no_to_bool(client, :health_prioritized, row[:health_prioritized])

    result[:last_name] = "Anonymous - #{row[:client_identifier]}"
    result[:first_name] = "Anonymous - #{row[:client_identifier]}"
    result[:entry_date] ||= Date.current

    result
  end

  def parse_date(client, column, date)
    return date if date.is_a?(Date)
    return Date.parse('1900-01-01') + date.days if date.is_a?(Integer)
    return Date.parse(date) if Date.is_a?(String)

    client.errors.add(column, "'#{date}' cannot be parsed as a date")
    raise 'invalid date'
  end

  def check_date(client, date)
    if date < Date.parse('2000-01-01') || date > Date.parse('2999-12-31')
      client.errors.add('Information collected at', "'#{date}' is out of expected range")
      raise 'date out of range'
    end
  rescue StandardError
    client.errors.add('Information collected at', "'#{date}' cannot be parsed as a date")
    raise 'invalid date'
  end

  def convert_to_neighborhood_interests(client, field, val)
    neighborhood_name = case val.to_i
    when 1
      'Fort Worth'
    when 2
      'Arlington'
    else
      # accept text values, we'll add an error if it's not a known neighborhood
      val
      # leaving the following 2 lines until we have confirmation that this change is ok
      # client.errors.add(field, "Unable to parse neighborhood identifier: #{val}")
      # return nil # Don't convert invalid values
    end
    neighborhood = Neighborhood.text_search(neighborhood_name).first
    unless neighborhood.present?
      client.errors.add(field, "Neighborhood '#{neighborhood_name}' not found.")
      return nil
    end
    [neighborhood.id]
  end

  SECONDS_IN_DAY = 86_400
  DAYS_IN_THREE_YEARS = 1095

  def convert_to_days(client, raw)
    duration_text = begin
      raw.downcase.squish
    rescue StandardError
      raw.to_s
    end
    # more_than = duration_text.include?('more than')
    count = duration_text.scan(/[0-9]+/).first.to_i
    half = duration_text.include?('1/2')
    half_duration = 0
    case duration_text
    when /week/
      duration = count.weeks
      half_duration = 1.weeks / 2 if half
    when /month|mth/
      duration = count.months
      half_duration = 1.months / 2 if half
    when /year/
      duration = count.years
      half_duration = 1.years / 2 if half
    else # if no unit, assume months because that is what is in the column header
      duration = count.months
      half_duration = 1.months / 2 if half
    end
    days = (duration + half_duration) / SECONDS_IN_DAY
    # Capped at 3 years
    [days, DAYS_IN_THREE_YEARS].min
  rescue StandardError
    client.errors.add('Cumulative months homeless in last three years', "Unable to parse '#{raw}' as a duration")
    raise 'unable to parse days'
  end

  def yes_no_to_bool(client, field, val)
    text = val&.to_s&.downcase&.strip
    if ['yes', 'y'].include?(text)
      true
    elsif ['no', 'n'].include?(text)
      false
    else
      client.errors.add(field, "Unexpected value '#{val}'")
      raise 'unexpected value'
    end
  end

  def convert_to_score(client, field, val)
    return 0 if val.blank?

    begin
      Integer(val)
    rescue StandardError
      client.errors.add(field, "Unexpected value '#{val}'")
      raise 'unexpected value'
    end
  end
  alias convert_to_number convert_to_score

  private def parse_xlsx
    StringIO.open(content) do |stream|
      @xlsx = Roo::Excelx.new(stream)
    end
  end

  def self.file_header
    file_attributes.values
  end

  def file_attributes
    self.class.file_attributes
  end

  def self.file_attributes
    {
      shelter_location: 'Shelter Location',
      disabling_condition: 'Disabled Per HUD Language',
      client_identifier: 'Home-base ID',
      substance_abuse_problem: 'Substance Use Disability',
      mental_health_problem: 'Mental Health Disability',
      occurrences_of_homelessness: 'Occurrences of Homelessness in Last Three Years',
      days_homeless: 'Cumulative days Homeless',
      family_member: 'Family of at least one Adult and one child',
      sixty_plus: 'Age greater than 60 years of age',
      is_currently_youth: 'Age less than 24 years of age',
      chronic_homeless: 'Permanent Supportive Housing Eligible',
      pregnancy_status: 'Currently first time pregnant 28 weeks or less',
      veteran: 'Veteran Status',
      hiv_aids: 'HOPWA Eligible',
      health_prioritized: 'Prioritized for Health',
    }.freeze
  end
end
