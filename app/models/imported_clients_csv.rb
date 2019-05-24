class ImportedClientsCsv < ActiveRecord::Base

  mount_uploader :file, ImportedClientsCsvFileUploader

  FORM_TIMESTAMP = 0
  HOUSING_STATUS = 3
  RESIDENT = 4
  DAYS_HOMELESS = 5
  SHELTER_NAME = 7
  ENTRY_DATE = 8
  CASE_MANAGER_NAME = 9
  CASE_MANAGER_PHONE = 10
  CASE_MANAGER_EMAIL = 11
  HOH_FIRST_NAME = 13
  HOH_LAST_NAME = 14
  HOH_PHONE = 15
  HOH_EMAIL = 16
  ANNUAL_INCOME = 17
  VOUCHER = 18
  VOUCHER_AGENCY = 19
  CHILDREN = 20
  FAMILY_STUDIO = 21
  FAMILY_ONE_BR = 22
  SRO = 23
  INDIVIDUAL_STUDIO = 24
  BEDROOMS = 25
  ACCESSIBILITY_NEEDS = 26
  INTERESTED_IN_DISABLED_HOUSING = 27
  FIFTY_FIVE = 28
  SIXTY_TWO = 29
  VETERAN = 30
  NEIGHBORHOODS = 31

  attr_reader :added, :touched, :problems

  def initialize(attributes = {})
    super(attributes)
    @added = 0
    @touched = 0
    @problems = {}
  end

  def import
    CSV.parse(content, headers: true) do |row|
      first_name = row[HOH_FIRST_NAME]
      if first_name.blank?
        add_problem(row, 'HoH First Name', 'is required')
        next
      end

      last_name = row[HOH_LAST_NAME]
      if last_name.blank?
        add_problem(row, 'HoH Last Name', 'is required')
        next
      end

      email = row[HOH_EMAIL]
      if email.blank?
        add_problem(row, 'HoH Email', 'is required')
        next
      end

      client = ImportedClient.where(
        first_name: first_name,
        last_name: last_name,
        email: email
      ).first_or_initialize do |client|
        @added += 1
        client.interested_in_set_asides = true
        client.available = false
        client.identified = true
      end
      if client.imported_timestamp.nil? || row[FORM_TIMESTAMP].to_time > client.imported_timestamp
        @touched += 1 if client.imported_timestamp.present?
        client.update!(
          imported_timestamp: row[FORM_TIMESTAMP].to_time,

          set_asides_housing_status: housing_status(row),
          domestic_violence: fleeing_domestic_violence?(row),
          set_asides_resident: resident?(row),
          days_homeless_in_the_last_three_years: days_homeless(row),
          shelter_name: shelter_name(row),
          entry_date: entry_date(row),
          case_manager_contact_info: case_manager(row),
          phone_number: phone_number(row),
          income_total_monthly: monthly_income(row),
          have_tenant_voucher: yes_no_to_bool(row[VOUCHER]),
          voucher_agency: voucher_agency(row),
          children_info: row[CHILDREN],
          family_member: family?(row),
          studio_ok: studio_ok?(row),
          one_br_ok: yes_no_to_bool(row[FAMILY_ONE_BR]),
          sro_ok: yes_no_to_bool(row[SRO]),
          required_number_of_bedrooms: bedrooms(row),
          requires_wheelchair_accessibility: wheelchair_accessible?(row),
          requires_elevator_access: elevator_access?(row),
          disabling_condition: disability?(row),
          interested_in_disabled_housing: yes_no_to_bool(row[INTERESTED_IN_DISABLED_HOUSING]),
          fifty_five_plus: yes_no_to_bool(row[FIFTY_FIVE]),
          sixty_two_plus: yes_no_to_bool(row[SIXTY_TWO]),
          date_of_birth: calculate_dob(row),
          veteran: yes_no_to_bool(row[VETERAN]),
          neighborhood_interests: determine_neighborhood_interests(row),
        )
      end
    end
  end

  def housing_status(row)
    status = row[HOUSING_STATUS]
    if status.present?
      status
    else
      add_problem(row, 'Housing Status', 'is required')
      nil
    end
  end

  def fleeing_domestic_violence?(row)
    status = row[HOUSING_STATUS]
    status.present? && status.include?('OR A.2)')
  end

  def resident?(row)
    row[RESIDENT].present?
  end

  def days_homeless(row)
    begin
      days = Integer(row[DAYS_HOMELESS])
      if days > 1096
        add_problem(row, 'Days Homeless', 'is greater than 1096')
      end
      days
    rescue
      add_problem(row, 'Days Homeless', "#{row[DAYS_HOMELESS]} is not a valid number")
      0
    end
  end

  def shelter_name(row)
    name = row[SHELTER_NAME]
    if name.present?
      name
    else
      add_problem(row, 'Shelter Name', 'is required')
      nil
    end
  end

  def entry_date(row)
    begin
      date = row[ENTRY_DATE].to_date
      if date.present?
        date
      else
        add_problem(row, 'Entry Date', 'is required')
        nil
      end
    rescue
      add_problem(row, 'Entry Date', "#{row[ENTRY_DATE]} is not a valid date")
      nil
    end
  end

  def case_manager(row)
    info = []
    name = row[CASE_MANAGER_NAME]
    if name.present?
    info << name
    else
      add_problem(row, 'Case Manager Name', 'is required')
    end
    phone = row[CASE_MANAGER_PHONE]
    if phone.present?
      info << phone
    else
      add_problem(row, 'Case Manager Phone', 'is required')
    end
    email = row[CASE_MANAGER_EMAIL]
    if email.present?
      info << email
    else
      add_problem(row, 'Case Manager Email', 'is required')
    end
    info.join(' / ')
  end

  def phone_number(row)
    phone = row[HOH_PHONE]
    if phone.present?
      phone
    else
      add_problem(row, 'Client Phone', 'is required')
      nil
    end
  end

  def monthly_income(row)
    begin
      Float(row[ANNUAL_INCOME]) / 12
    rescue
      add_problem(row, 'Annual Income', "#{row[ANNUAL_INCOME]} is not a valid number")
      0
    end
  end

  def yes_no_to_bool(val)
    val == "Yes"
  end

  def voucher_agency(row)
    agency = row[VOUCHER_AGENCY]
    if yes_no_to_bool(row[VOUCHER]) && agency.present?
      agency
    else
      add_problem(row, 'Voucher Agency', 'is required')
      nil
    end
  end

  def family?(row)
    row[CHILDREN].present? || row[FAMILY_STUDIO] != 'Not Applicable' || row[FAMILY_ONE_BR] != 'Not Applicable'
  end

  def studio_ok?(row)
    yes_no_to_bool(row[FAMILY_STUDIO]) || yes_no_to_bool(row[INDIVIDUAL_STUDIO])
  end

  def bedrooms(row)
    bedrooms = row[BEDROOMS].gsub(/bedroom/, '').to_i
    if bedrooms > 1
      bedrooms
    else
      nil
    end
  end

  def wheelchair_accessible?(row)
    needs = row[ACCESSIBILITY_NEEDS]
    needs.present? && needs.include?('wheelchair')
  end

  def elevator_access?(row)
    needs = row[ACCESSIBILITY_NEEDS]
    needs.present? && needs.include?('elevator')
  end

  def disability?(row)
    needs = row[ACCESSIBILITY_NEEDS]
    wheelchair_accessible?(row) || elevator_access?(row) || needs.include?('other accessibility')
  end

  def calculate_dob(row)
    return Date.new(Date.today.year - 62) if yes_no_to_bool(row[SIXTY_TWO])
    return Date.new(Date.today.year - 55) if yes_no_to_bool(row[FIFTY_FIVE])
    return nil
  end

  def determine_neighborhood_interests(row)
    neighborhoods = row[NEIGHBORHOODS].split(';')
    interests = neighborhoods.flat_map do |neighborhood_name|
      Neighborhood.where(name: neighborhood_name).pluck(:id)
    end
    if interests.size != neighborhoods.size
      add_problem(row, 'Neighborhoods', 'not all neighborhoods are valid')
    end
    interests
  end

  def add_problem(row, field, description)
    client = [ row[HOH_FIRST_NAME], row[HOH_LAST_NAME], row[HOH_EMAIL] ]
    @problems[client] ||= []
    @problems[client] << {field: field, description: description}
  end
end