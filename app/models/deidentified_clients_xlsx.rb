class DeidentifiedClientsXlsx < ActiveRecord::Base

  mount_uploader :file, DeidentifiedClientsXlsxFileUploader
  attr_reader :added, :touched, :problems, :clients

  def valid_header?
    parse_xlsx if ! @xlsx

    # Assume data is on default sheet, and header starts at A1
    @xlsx.row(1) == self.class.file_header
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

    result[:updated_at] = parse_date(client, 'Information collected at', row[:updated_at])
    check_date(client, result[:updated_at])
    result[:entry_date] = parse_date(client, 'Date entered program', row[:entry_date])
    result.delete(:exit_date)
    result.delete(:date_first_homeless)
    result.delete(:occurrences_of_homelessness)
    result[:days_homeless_in_the_last_three_years] = convert_to_days(client, row[:days_homeless_in_the_last_three_years])
    result[:family_member] = yes_no_to_bool(client, :family_member, row[:family_member])
    result[:date_of_birth] = parse_date(client, 'Date of birth (client)', row[:date_of_birth])
    result[:veteran] = yes_no_to_bool(client, :veteran, row[:veteran])
    result[:disabling_condition] = yes_no_to_bool(client, :disabling_condition, row[:disabling_condition])
    result[:developmental_disability] = yes_no_to_bool(client, :developmental_disability, row[:developmental_disability])
    result[:physical_disability] = yes_no_to_bool(client, :physical_disability, row[:physical_disability])
    result[:chronic_health_condition] = yes_no_to_bool(client, :chronic_health_condition, row[:chronic_health_condition])
    result[:mental_health_problem] = yes_no_to_bool(client, :mental_health_problem, row[:mental_health_problem])
    result[:substance_abuse_problem] = yes_no_to_bool(client, :substance_abuse_problem, row[:substance_abuse_problem])
    result[:hopwa] = yes_no_to_bool(client, :hopwa, row[:hopwa])
    result[:vispdat_score] = convert_to_score(client, :vispdat_score, row[:vispdat_score])
    result[:vispdat_priority_score] = ProjectClient.calculate_vispdat_priority_score(
      vispdat_score: result[:vispdat_score],
      days_homeless: result[:days_homeless_in_the_last_three_years],
      veteran_status: result[:veteran]
    )
    result.delete(:hopwa)
    result.delete(:last_zip)

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
        when /month/
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
    text = val&.downcase
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

  private def parse_xlsx
    StringIO.open(content) do |stream|
      @xlsx = Roo::Excelx.new(stream)
    end

  end

  def self.file_header
    [
      'Date Information Collected',
      'Date Entered Program',
      'Date Exit Program',
      'Homebase ID',
      'Date First became Homeless',
      'Occurrences of Homelessness in Last Three Years',
      'Cumulative Months Homeless in Last Three Years',
      'Family of at least One Adult and Once Child',
      'Date of Birth (Client)',
      'Veteran Status',
      'Disabling Condition* ',
      'Physical Disabilty ',
      'Developmental Disability',
      'Chronic Health Condition',
      'Mental Health Problem',
      'Substance Abuse Disorder',
      'HOPWA',
      'Client\'s last residential zip code ',
      'VI-SPDAT Score'
    ].freeze
  end

  private def file_attributes
    [
      :updated_at,
      :entry_date,
      :exit_date, # not in model
      :client_identifier,
      :date_first_homeless, # not in model
      :occurrences_of_homelessness, # not in model
      :days_homeless_in_the_last_three_years,
      :family_member,
      :date_of_birth,
      :veteran,
      :disabling_condition,
      :physical_disability,
      :developmental_disability,
      :chronic_health_condition,
      :mental_health_problem,
      :substance_abuse_problem,
      :hopwa, # not in model
      :last_zip, # not in model
      :vispdat_score,
    ]
  end

end