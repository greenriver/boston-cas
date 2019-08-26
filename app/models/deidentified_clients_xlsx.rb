class DeidentifiedClientsXlsx < ActiveRecord::Base

  mount_uploader :file, DeidentifiedClientsXlsxFileUploader

  def valid_header?
    parse_xlsx if ! @xlsx

    # Assume data is on default sheet, and header starts at A1
    @xlsx.row(1) == file_header
  end

  def import
    if valid_header?
      @xlsx.each_with_index do |raw, index|
        next if skip?(raw, index)

        row = Hash[file_attributes.zip(raw)]
        client = DeidentifiedClient.find_or_create_by(client_identifier: row[:client_identifier])
        cleaned = clean_row(row) rescue next
        cleaned[:identified] = false # mark as de-identified client
        client.update(cleaned)
      end
    end
  end

  # Ignore the header, and empty rows
  def skip?(row, index)
    index == 0 || row[3].blank?
  end

  def clean_row(row)
    result = row.dup
    check_date(result[:updated_at])
    result.delete(:exit_date)
    result.delete(:date_first_homeless)
    result.delete(:occurrences_of_homelessness)
    result[:days_homeless_in_the_last_three_years] = convert_to_days(row[:days_homeless_in_the_last_three_years])
    result[:family_member] = yes_no_to_bool(row[:family_member])
    result[:veteran] = yes_no_to_bool(row[:veteran])
    result[:disabling_condition] = yes_no_to_bool(row[:disabling_condition])
    result[:developmental_disability] = yes_no_to_bool(row[:developmental_disability])
    result[:physical_disability] = yes_no_to_bool(row[:physical_disability])
    result[:chronic_health_condition] = yes_no_to_bool(row[:chronic_health_condition])
    result[:mental_health_problem] = yes_no_to_bool(row[:mental_health_problem])
    result[:substance_abuse_problem] = yes_no_to_bool(row[:substance_abuse_problem])
    result[:hopwa] = yes_no_to_bool(row[:hopwa])
    result[:assessment_score] = row[:assessment_score].to_i
    result.delete(:hopwa)
    result.delete(:last_zip)

    result
  end

  def check_date(date)
    if date < Date.parse('2000-01-01') || date > Date.parse('2999-12-31')
      raise "bad date"
    end
  end

  SECONDS_IN_DAY = 86400
  DAYS_IN_THREE_YEARS = 1095

  def convert_to_days(raw)
    begin
      duration_text = raw.downcase.squish
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
      end
      days = ( duration + half_duration ) / SECONDS_IN_DAY
      # Capped at 3 years
      [days, DAYS_IN_THREE_YEARS].min
    rescue
      # unparseable
      nil
    end
  end

  def yes_no_to_bool(text)
    text&.downcase == 'yes'
  end

  private def parse_xlsx
    StringIO.open(content) do |stream|
      @xlsx = Roo::Excelx.new(stream)
    end

  end
  
  private def file_header
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
    ]
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
      :assessment_score,
    ]
  end

end