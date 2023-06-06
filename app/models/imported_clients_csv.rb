###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ImportedClientsCsv < ApplicationRecord
  mount_uploader :file, ImportedClientsCsvFileUploader

  attr_reader :added, :touched, :problems, :clients

  def initialize(attributes = {})
    super(attributes)
    @added = 0
    @touched = 0
    @clients = []
  end

  def import(agency)
    return false unless check_header

    CSV.parse(content, headers: true) do |row|
      first_name = row[header.hoh_first_name]
      last_name = row[header.hoh_last_name]
      email = row[header.hoh_email]

      client = ImportedClient.where(
        first_name: first_name,
        last_name: last_name,
        email: email,
      ).first_or_initialize do |c|
        @added += 1
        c.interested_in_set_asides = true # import is currently for set-asides, mark everyone as interested
        c.available = true
        c.identified = true
      end
      assessment = client.current_assessment || client.client_assessments.build

      timestamp = convert_to_time(row[header.timestamp])
      if assessment.imported_timestamp.nil? || timestamp > assessment.imported_timestamp
        @clients << client
        @touched += 1 if assessment.imported_timestamp.present?
        assessment.update(
          interested_in_set_asides: true,
          imported_timestamp: timestamp,

          set_asides_housing_status: row[header.housing_status],
          domestic_violence: fleeing_domestic_violence?(row),
          days_homeless_in_the_last_three_years: days_homeless(row),
          shelter_name: row[header.shelter_name],
          entry_date: convert_to_date(row[header.date_entered_shelter]),
          case_manager_contact_info: case_manager(client, row),
          phone_number: row[header.hoh_phone],
          income_total_monthly: monthly_income(row),
          have_tenant_voucher: yes_no_to_bool(row[header.has_voucher]),
          voucher_agency: row[header.voucher_agency],
          children_info: row[header.children],
          family_member: family?(row),
          studio_ok: studio_ok?(row),
          one_br_ok: yes_no_to_bool(row[header.family_one_br_ok]),
          sro_ok: yes_no_to_bool(row[header.individual_sro_ok]),
          required_number_of_bedrooms: bedrooms(row),
          requires_wheelchair_accessibility: wheelchair_accessible?(row),
          requires_elevator_access: elevator_access?(row),
          disabling_condition: disability?(row),
          interested_in_disabled_housing: yes_no_to_bool(row[header.interested_in_disabled_housing]),
          veteran: yes_no_to_bool(row[header.veteran]),
          neighborhood_interests: determine_neighborhood_interests(client, row),
        )
        client.update(
          agency_id: agency&.id,
          date_of_birth: calculate_dob(row),
          shelter_name: row[header.shelter_name],
        )
      end
    end
    true
  end

  def clean_integer(str)
    return nil unless str.to_i.to_s == str

    str.to_i
  end

  def convert_to_time(str)
    return unless str

    return DateTime.strptime(str, '%m/%d/%Y %H:%M:%S')
  rescue ArgumentError
    begin
      return DateTime.strptime(str, '%m/%d/%Y %H:%M')
    rescue Date::Error
      DateTime.parse(str)
    end
    DateTime.parse(str)
  end

  def convert_to_date(str)
    return unless str

    Date.strptime(str, '%m/%d/%Y')
  rescue ArgumentError
    Date.parse(str)
  end

  def fleeing_domestic_violence?(row)
    status = row[header.housing_status]
    status.present? && status.include?('A.2')
  end

  def days_homeless(row)
    Integer(row[header.days_homeless])
    rescue ArgumentError, TypeError
      nil
  end

  def case_manager(client, row)
    info = []
    name = row[header.case_manager_name]
    if name.present?
      info << name
    else
      client.errors.add(:case_manager_contact_info, 'case manager name can\'t be blank')
    end
    phone = row[header.case_manager_phone]
    if phone.present?
      info << phone
    else
      client.errors.add(:case_manager_contact_info, 'case manager phone can\'t be blank')
    end
    email = row[header.case_manager_email]
    if email.present?
      info << email
    else
      client.errors.add(:case_manager_contact_info, 'case manager email can\'t be blank')
    end

    alternate_contact = []
    alternate_contact << row[header.alternative_contact_name]
    alternate_contact << row[header.alternative_contact_phone]
    alternate_contact << row[header.alternative_contact_email]

    if alternate_contact.present?
      info << 'Alternate contact: '
      info += alternate_contact
    end

    info.join(' / ')
  end

  def monthly_income(row)
    Float(row[header.annual_income]) / 12
  rescue ArgumentError, TypeError
    nil
  end

  def yes_no_to_bool(val)
    val == 'Yes'
  end

  def family?(row)
    row[header.children].present? || row[header.family_studio_ok] != 'Not Applicable' || row[header.family_one_br_ok] != 'Not Applicable'
  end

  def studio_ok?(row)
    yes_no_to_bool(row[header.family_studio_ok]) || yes_no_to_bool(row[header.individual_studio_ok])
  end

  def bedrooms(row)
    return nil unless row[header.bedrooms].present?

    bedrooms = row[header.bedrooms].gsub(/bedroom/, '').to_i
    return bedrooms if bedrooms > 1

    nil
  end

  def wheelchair_accessible?(row)
    needs = row[header.accessibility_needs]
    needs.present? && needs.include?('wheelchair')
  end

  def elevator_access?(row)
    needs = row[header.accessibility_needs]
    needs.present? && needs.include?('elevator')
  end

  def disability?(row)
    needs = row[header.accessibility_needs]
    wheelchair_accessible?(row) || elevator_access?(row) || needs.include?('other accessibility')
  end

  def calculate_dob(row)
    year = row[header.hoh_year_of_birth]
    return nil unless year.present?

    client.errors.add(:hoh_year_of_birth, 'four-digit year is required') unless year.to_i >= 1000
    "#{year}-01-01".to_date
  end

  def determine_neighborhood_interests(client, row)
    neighborhoods = row[header.neighborhoods].split(';')
    interests = neighborhoods.flat_map do |neighborhood_name|
      Neighborhood.where(name: neighborhood_name).pluck(:id)
    end
    client.errors.add(:neighborhood_interests, 'not all neighborhoods are valid') if interests.size != neighborhoods.size
    interests
  end

  def check_header
    incoming = CSV.parse(content.lines.first).flatten.to_set
    expected = expected_header.values.to_set

    # You can update the header string with File.read('path/to/file.csv').lines.first
    # Using CSV parse in case the quoting styles differ
    return true if incoming == expected

    differences = (incoming ^ expected).to_a.join(', ')
    Rails.logger.error("Headers do not match: #{differences}")

    false
  end

  def expected_header
    {
      timestamp: 'Timestamp',
      email: 'Email Address',
      provider_ack: 'Provider Acknowledgment',
      housing_status: 'Household is currently:',
      days_homeless: 'Cumulative number of days in the last three years',
      provider_ack_2: 'Provider Acknowledgment 2',
      shelter_name: 'Name of shelter where household resides.',
      date_entered_shelter: 'Date household entered above mentioned shelter.',
      case_manager_name: 'Case manager/shelter provider contact name',
      case_manager_phone: 'Case manager/shelter provider contact phone number',
      case_manager_email: 'Case manager/shelter provider email address',
      alternative_contact_name: 'Alternate case manager/shelter provider contact name',
      alternative_contact_phone: 'Alternate phone number',
      alternative_contact_email: 'Alternate email address',
      signature: 'Household Acknowledgment',
      hoh_last_name: 'Last Name (Head of Household)',
      hoh_first_name: 'First Name (Head of Household)',
      hoh_phone: 'Head of household phone number',
      hoh_email: 'Head of household email address',
      hoh_age_range: 'Head of Household Age',
      hoh_year_of_birth: 'Head of Household Year of Birth',
      annual_income: 'What is the estimated annual income for your household next year?',
      has_voucher: 'Do you currently have a tenant-based housing choice voucher?',
      voucher_agency: 'Voucher administering housing authority/agency',
      children: 'Children Age & Gender',
      family_studio_ok: 'If you are a family with children, would you consider a studio?',
      family_one_br_ok: 'If you are a family with children, would you consider a one bedroom?',
      individual_sro_ok: 'If you are an individual, would you consider living in an SRO (single room occupancy)?',
      individual_studio_ok: 'If you are an individual, would you consider living in a studio?',
      bedrooms: 'If you need a bedroom size larger than SRO, studio, or 1 bedroom, please choose a size below.',
      accessibility_needs: 'Are you seeking any of the following due to a disability?',
      interested_in_disabled_housing: 'Interest in units for disabled persons?',
      veteran: 'Are you a veteran?',
      neighborhoods: 'Neighborhood Preference',
    }.freeze
  end

  def header
    @header ||= OpenStruct.new(expected_header)
  end
end
