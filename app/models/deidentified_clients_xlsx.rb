class DeidentifiedClientsXlsx < ApplicationRecord

  mount_uploader :file, DeidentifiedClientsXlsxFileUploader
  attr_reader :added, :touched, :problems, :clients

  def valid_header?
    parse_xlsx if ! @xlsx

    # Assume data is on default sheet, and header starts at A1
    @xlsx.row(1).map(&:strip).map(&:downcase) == self.class.file_header.map(&:strip).map(&:downcase)
  end

  def import(agency, force_update: false)
    @added = 0
    @touched = 0
    @clients = []

    if valid_header?
      @xlsx.each_with_index do |raw, index|
        next if skip?(raw, index)

        row = Hash[file_attributes.zip(raw)]
        client = DeidentifiedClient.where(client_identifier: row[:client_identifier]).first_or_initialize
        @clients << client
        cleaned = clean_row(client, row) rescue next
        cleaned[:agency_id] = agency&.id
        cleaned[:identified] = false # mark as de-identified client
        if force_update || client.updated_at.nil? || cleaned[:updated_at] > client.updated_at.to_date
          @added +=1 if client.updated_at.nil?
          @touched += 1 if client.updated_at.present?
          client.update(cleaned)
          assessment = client.current_assessment || client.client_assessments.build
          assessment = client.update_assessment_from_client(assessment)
          assessment.save
        end
      end
    end
  end

  # Ignore the header, and empty rows
  def skip?(row, index)
    index == 0 || row[3].blank?
  end

  def clean_row(client, row)
    result = row.dup

    result.delete(:shelter_location)
    result.delete(:referral_date)
    # :client_identifier
    result.delete(:date_first_homeless)
    result.delete(:occurrences_of_homelessness)
    result[:days_homeless_in_the_last_three_years] = convert_to_days(client, row[:days_homeless_in_the_last_three_years])
    result[:family_member] = yes_no_to_bool(client, :family_member, row[:family_member])
    result[:disabling_condition] = yes_no_to_bool(client, :disabling_condition, row[:disabling_condition])
    # "Permanent Supportive Housing Eligible" is a proxy for "Disabling Condition" and at least 365 days homeless.
    if result[:disabling_condition] && result[:days_homeless_in_the_last_three_years] < 365
      result[:days_homeless_in_the_last_three_years] = 365
    end
    result[:required_number_of_bedrooms] = convert_to_number(client, :required_number_of_bedrooms, row[:required_number_of_bedrooms])
    result[:veteran] = yes_no_to_bool(client, :veteran, row[:veteran])
    result[:hiv_aids] = yes_no_to_bool(client, :hiv_aids, row[:hiv_aids])
    result[:vispdat_score] = convert_to_score(client, :vispdat_score, row[:vispdat_score])
    result[:vispdat_priority_score] = ProjectClient.calculate_vispdat_priority_score(
      vispdat_score: result[:vispdat_score],
      days_homeless: result[:days_homeless_in_the_last_three_years],
      veteran_status: result[:veteran])

    result[:last_name] = "Anonymous - #{row[:client_identifier]}"
    result[:first_name] = "Anonymous - #{row[:client_identifier]}"

    result
  end

  def parse_date(client, column, date)
    return date if date.is_a?(Date)
    return Date.parse('1900-01-01') + date.days if date.is_a?(Integer)
    return Date.parse(date) if Date.is_a?(String)

    client.errors.add(column, "'#{date}' cannot be parsed as a date")
    raise "invalid date"
  end

  def check_date(client, date)
    begin
      if date < Date.parse('2000-01-01') || date > Date.parse('2999-12-31')
        client.errors.add('Information collected at', "'#{date}' is out of expected range")
        raise "date out of range"
      end
    rescue
      client.errors.add('Information collected at', "'#{date}' cannot be parsed as a date")
      raise "invalid date"
    end
  end

  SECONDS_IN_DAY = 86400
  DAYS_IN_THREE_YEARS = 1095

  def convert_to_days(client, raw)
    begin
      duration_text = raw.downcase.squish rescue raw.to_s
      more_than = duration_text.include?('more than')
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
      days = ( duration + half_duration ) / SECONDS_IN_DAY
      # Capped at 3 years
      [days, DAYS_IN_THREE_YEARS].min
    rescue
      client.errors.add('Cumulative months homeless in last three years', "Unable to parse '#{raw}' as a duration")
      raise 'unable to parse days'
    end
  end

  def yes_no_to_bool(client, field, val)
    text = val&.downcase&.strip
    if text == 'yes' || text == 'y'
      true
    elsif text == 'no' || text == 'n'
      return false
    else
      client.errors.add(field, "Unexpected value '#{val}'")
      raise 'unexpected value'
    end
  end

  def convert_to_score(client, field, val)
    return 0 if val.blank?
    begin
      Integer(val)
    rescue
      client.errors.add(field, "Unexpected value '#{val}'")
      raise 'unexpected value'
    end
  end
  alias_method :convert_to_number, :convert_to_score

  private def parse_xlsx
    StringIO.open(content) do |stream|
      @xlsx = Roo::Excelx.new(stream)
    end

  end

  def self.file_header
    [
      'Shelter Location', # NEW
      'Referral Date', # NEW
      'Home-base ID',
      'Date First became Homeless',
      'Occurrences of Homelessness in Last Three Years',
      'Cumulative Months Homeless in Last Three Years',
      'Family of at least one Adult and one child',
      'Permanent Supportive Housing Eligible', # Was 'Disabling Condition*'
      'Minimum Bedroom Size', # NEW
      'Veteran Status',
      'HOPWA Eligible',
      'VI-SPDAT Score',
    ].freeze
  end

  private def file_attributes
    [
      :shelter_location, # not in model
      :referral_date, # not in model
      :client_identifier,
      :date_first_homeless, # not in model
      :occurrences_of_homelessness, # not in model
      :days_homeless_in_the_last_three_years,
      :family_member,
      :disabling_condition,
      :required_number_of_bedrooms,
      :veteran,
      :hiv_aids,
      :vispdat_score,
    ]
    # [
    #   :updated_at,
    #   :entry_date,
    #   :exit_date, # not in model
    #   :client_identifier,
    #   :date_first_homeless, # not in model
    #   :occurrences_of_homelessness, # not in model
    #   :days_homeless_in_the_last_three_years,
    #   :family_member,
    #   :date_of_birth,
    #   :veteran,
    #   :disabling_condition,
    #   :physical_disability,
    #   :developmental_disability,
    #   :chronic_health_condition,
    #   :mental_health_problem,
    #   :substance_abuse_problem,
    #   :hopwa, # not in model
    #   :last_zip, # not in model
    #   :vispdat_score,
    # ]
  end

end