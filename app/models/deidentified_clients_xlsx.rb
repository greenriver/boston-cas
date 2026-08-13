###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class DeidentifiedClientsXlsx < ApplicationRecord
  # Remove CarrierWave dependency
  # mount_uploader :file, DeidentifiedClientsXlsxFileUploader

  include FileContentValidator

  attr_accessor :agency_id, :update_availability
  attr_reader :added, :touched, :skipped_identifiers, :problems, :clients

  # Validate file content before creating record
  def self.validate_file_content(file_content, claimed_content_type = nil)
    allowed_types = [
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-excel',
    ]
    super(file_content, claimed_content_type, allowed_types, '.xlsx')
  end

  def agency_options_for_select(user)
    DeidentifiedClient.agencies_available_to(user).order(name: :asc).pluck(:name, :id).to_h
  end

  def valid_header?
    parse_xlsx unless @xlsx

    # Assume data is on default sheet, and header starts at A1
    @xlsx.row(1).map(&:strip).map(&:downcase) == self.class.file_header.map(&:strip).map(&:downcase)
  end

  def import(agency, update_availability: false)
    @added = 0
    @touched = 0
    @skipped_identifiers = []
    @clients = []
    @update_availability = update_availability

    return unless valid_header?

    # Internal (non-user) errors are buffered here and reported to Sentry only after the
    # transaction commits
    sentry_queue = []

    unapplied_client_ids = []

    # Availability is reset up front, so a raise anywhere in the loop must roll the whole roster
    # back rather than leave every client in the agency unavailable.
    DeidentifiedClient.transaction do
      # Must be plucked before the update_all below marks every client in the agency unavailable.
      previously_available_ids = @update_availability ? DeidentifiedClient.where(agency: agency, available: true).pluck(:id) : []

      DeidentifiedClient.where(agency: agency).update_all(available: false) if @update_availability

      @xlsx.each_with_index do |raw, index|
        next if skip?(raw, index)

        row = Hash[file_attributes.keys.zip(raw)]

        # A Home-base ID is globally unique, so look the client up by ID alone If it's already
        # live under a *different* agency skip and report it
        client = DeidentifiedClient.find_by(client_identifier: row[:client_identifier]) ||
          DeidentifiedClient.new(agency: agency, client_identifier: row[:client_identifier])

        if client.persisted? && client.agency_id != agency&.id
          @skipped_identifiers << row[:client_identifier] unless @skipped_identifiers.include?(row[:client_identifier])
          next
        end

        @clients << client
        cleaned = begin
          clean_row(client, row)
        rescue StandardError => e
          # clean_row's helpers attach a field-level error before raising. Those are expected,
          # user-correctable data problems. But if nothing was attached then this is an
          # internal failure, report it and show a row-level message so the user knows which row
          # was dropped.
          if client.errors.empty?
            sentry_queue << e
            client.errors.add(:base, "Could not process row: #{e.message}")
          end
          unapplied_client_ids << client.id if client.persisted?
          next
        end

        cleaned[:agency_id] = agency&.id
        cleaned[:identified] = false # mark as de-identified client
        if @update_availability
          cleaned[:available] = true
          cleaned[:actively_homeless] = true
        end

        # A failed save is user-correctable bad data: leave the client in @clients so its
        # errors render in import.haml, and don't count it or touch its assessment.
        was_new = client.new_record?
        unless client.update(cleaned)
          # A false return with no validation errors means a callback halted the save due to
          # an internal error, not bad user data
          sentry_queue << "De-identified roster save halted for client #{client.client_identifier}" if client.errors.empty?
          unapplied_client_ids << client.id if client.persisted?
          next
        end

        was_new ? (@added += 1) : (@touched += 1)

        assessment = client.current_assessment
        assessment.actively_homeless = true if @update_availability
        assessment_type = Config.get(:deidentified_client_assessment) || 'DeidentifiedClientAssessment'
        assessment = build_assessment(client, agency, assessment_type) if assessment.nil? || assessment.class.name != assessment_type
        # maintain current active status
        client.actively_homeless = assessment.actively_homeless
        assessment = client.update_assessment_from_client(assessment)
        # Validation is skipped (we don't have the CE Event required fields), so a failure here
        # is a DB-level, non-user-correctable error. Raise loudly and roll back the tx
        assessment.save!(validate: false)
      end

      # A row that bailed out must be a no-op, so give its client back the availability the reset
      # took away — only for clients already available, since a row we couldn't read is no reason
      # to activate anyone.
      restorable_ids = unapplied_client_ids & previously_available_ids
      DeidentifiedClient.where(id: restorable_ids).update_all(available: true) if restorable_ids.any?
    end

    # Transaction committed, report the internal errors
    sentry_queue.each do |report|
      report.is_a?(Exception) ? Sentry.capture_exception(report) : Sentry.capture_message(report)
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
