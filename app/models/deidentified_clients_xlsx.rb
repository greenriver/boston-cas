###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class DeidentifiedClientsXlsx < ApplicationRecord
  mount_uploader :file, DeidentifiedClientsXlsxFileUploader
  attr_accessor :update_availability
  attr_reader :added, :touched, :problems, :clients

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

    DeidentifiedClient.update_all(available: false) if @update_availability

    @xlsx.each_with_index do |raw, index|
      next if skip?(raw, index)

      row = Hash[file_attributes.keys.zip(raw)]
      client = DeidentifiedClient.where(client_identifier: row[:client_identifier]).first_or_initialize
      @clients << client
      cleaned = begin
        clean_row(client, row)
      rescue StandardError
        next
      end
      cleaned[:agency_id] = agency&.id
      cleaned[:identified] = false # mark as de-identified client
      cleaned[:available] = true if @update_availability

      @added += 1 if client.updated_at.nil?
      @touched += 1 if client.updated_at.present?
      client.update(cleaned)

      assessment = client.current_assessment
      assessment_type = Config.get(:deidentified_client_assessment) || 'DeidentifiedClientAssessment'
      assessment = build_assessment(client, agency, assessment_type) if assessment.nil? || assessment.class.name != assessment_type
      assessment = client.update_assessment_from_client(assessment)
      assessment.save(validate: false) # We don't have the CE Event required fields
    end
  end

  def build_assessment(client, agency, assessment_type)
    assessment_type.constantize.new(assessment_type: assessment_type, agency_id: agency.id, non_hmis_client_id: client.id)
  end

  # Ignore the header, and empty rows
  def skip?(row, index)
    index.zero? || row[3].blank?
  end

  def clean_row(client, row)
    result = row.dup

    result.delete(:shelter_location)
    result.delete(:referral_date)
    # :client_identifier
    result.delete(:date_first_homeless)
    result.delete(:occurrences_of_homelessness)
    result[:days_homeless] = convert_to_number(client, :days_homeless, row[:days_homeless])
    result[:family_member] = yes_no_to_bool(client, :family_member, row[:family_member])
    result[:disabling_condition] = yes_no_to_bool(client, :disabling_condition, row[:disabling_condition])
    result[:is_currently_youth] = yes_no_to_bool(client, :is_currently_youth, row[:is_currently_youth])
    result[:sixty_plus] = yes_no_to_bool(client, :sixty_plus, row[:sixty_plus])
    result[:required_number_of_bedrooms] = convert_to_number(client, :required_number_of_bedrooms, row[:required_number_of_bedrooms])
    result[:veteran] = yes_no_to_bool(client, :veteran, row[:veteran])
    result[:hiv_aids] = yes_no_to_bool(client, :hiv_aids, row[:hiv_aids])
    result[:health_prioritized] = yes_no_to_bool(client, :health_prioritized, row[:health_prioritized])

    result[:last_name] = "Anonymous - #{row[:client_identifier]}"
    result[:first_name] = "Anonymous - #{row[:client_identifier]}"

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
    text = val&.downcase&.strip
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
      shelter_location: 'Shelter Location', # not in model
      referral_date: 'Referral Date', # not in model
      client_identifier: 'Home-base ID',
      date_first_homeless: 'Date First became Homeless', # not in model
      occurrences_of_homelessness: 'Occurrences of Homelessness in Last Three Years', # not in model
      days_homeless: 'Cumulative Days Homeless',
      family_member: 'Family of at least one Adult and one child',
      sixty_plus: 'Age greater than 60 years of age',
      is_currently_youth: 'Age less than 24 years of age',
      disabling_condition: 'Permanent Supportive Housing Eligible',
      required_number_of_bedrooms: 'Minimum Bedroom Size',
      veteran: 'Veteran Status',
      hiv_aids: 'HOPWA Eligible',
      health_prioritized: 'Prioritized for Health',
    }.freeze
  end
end
