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

  attr_reader :added, :touched, :problems, :clients

  def initialize(attributes = {})
    super(attributes)
    @added = 0
    @touched = 0
    @clients = []
  end

  def import
    if check_header
      CSV.parse(content, headers: true) do |row|
        first_name = row[HOH_FIRST_NAME]
        last_name = row[HOH_LAST_NAME]
        email = row[HOH_EMAIL]

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
          @clients << client
          @touched += 1 if client.imported_timestamp.present?
          client.update(
            imported_timestamp: row[FORM_TIMESTAMP].to_time,

            set_asides_housing_status: row[HOUSING_STATUS],
            domestic_violence: fleeing_domestic_violence?(row),
            set_asides_resident: resident?(row),
            days_homeless_in_the_last_three_years: days_homeless(row),
            shelter_name: row[SHELTER_NAME],
            entry_date: row[ENTRY_DATE].to_date,
            case_manager_contact_info: case_manager(client, row),
            phone_number: row[HOH_PHONE],
            income_total_monthly: monthly_income(row),
            have_tenant_voucher: yes_no_to_bool(row[VOUCHER]),
            voucher_agency: row[VOUCHER_AGENCY],
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
            neighborhood_interests: determine_neighborhood_interests(client, row),
          )
        end
      end
      return true
    else
      return false
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
    Integer(row[DAYS_HOMELESS]) rescue nil
  end

  def case_manager(client, row)
    info = []
    name = row[CASE_MANAGER_NAME]
    if name.present?
    info << name
    else
      client.errors.add(:case_manager_contact_info, 'case manager name can\'t be blank')
    end
    phone = row[CASE_MANAGER_PHONE]
    if phone.present?
      info << phone
    else
      client.errors.add(:case_manager_contact_info, 'case manager phone can\'t be blank')
    end
    email = row[CASE_MANAGER_EMAIL]
    if email.present?
      info << email
    else
      client.errors.add(:case_manager_contact_info, 'case manager email can\'t be blank')
    end
    info.join(' / ')
  end

  def monthly_income(row)
    Float(row[ANNUAL_INCOME]) / 12 rescue nil
  end

  def yes_no_to_bool(val)
    val == "Yes"
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

  def determine_neighborhood_interests(client, row)
    neighborhoods = row[NEIGHBORHOODS].split(';')
    interests = neighborhoods.flat_map do |neighborhood_name|
      Neighborhood.where(name: neighborhood_name).pluck(:id)
    end
    if interests.size != neighborhoods.size
      client.errors.add(:neighborhood_interests, 'not all neighborhoods are valid')
    end
    interests
  end

  def check_header
    content.lines.first == "\"Timestamp\",\"Username\",\"I certify that the below mentioned household fits each part of the Boston Homeless Set Aside Preference definition (below) to the best of my knowledge. I understand that as case manager I must obtain documentation of Homeless Status and retain that documentation in a client file to be provided upon request. I certify this by typing my name below.\",\"Household is currently: \",\"\",\"Cumulative number of days in the last three years that the household has met the definition above and is documented according to the documentation requirements below. This number cannot exceed 1096. \",\"I have obtained documentation according to the documentation requirements described above. I acknowledge that the household has voluntarily shown interest and willingness to participate in the Boston Homeless Set Aside Preference and move to a new apartment. I certify this by typing my name below. \",\"Name of shelter where household resides. If household is unsheltered, living on the street, please state this.\",\"Date household entered above mentioned shelter. If household is unsheltered, living on the street, please enter the date household began living on the street. \",\"Case manager/shelter provider contact name \",\"Case manager/shelter provider contact phone number \",\"Case manager/shelter provider email address\",\"I acknowledge the above statement by typing my name below. \",\"First Name of head of household \",\"Last Name of head of household \",\"Head of household phone number\",\"Head of household email address\",\"What is the estimated annual income for your household next year?\",\"Do you currently have a tenant-based housing choice voucher? \",\"If you have a tenant-based housing choice voucher, what is the administering housing authority/agency?\",\"What is the age and gender of each of the children in the household? (this information may be used by some housing providers to determine the number of bedrooms your household may receive priority for)\",\"If you are a family with children, would you consider a studio?\",\"If you are a family with children, would you consider a one bedroom?\",\"If you are an individual, would you consider living in an SRO (single room occupancy)?\",\"If you are an individual, would you consider living in a studio?\",\"If you need a bedroom size larger than SRO, studio, or 1 bedroom, please choose a size below. \",\"Are you seeking any of the following due to a disability?  If yes, you may have to provide documentation of disability - related need.)\",\"Are you interested in applying for housing units targeted for persons with disabilities?  (the definition of disability, as well as eligibility or preference criteria, may vary depending on the housing. You may have to provide documentation of a disability to qualify for these housing units.)\",\"Are you 55 years of age or older?\",\"Are you 62 years of age or older?\",\"Are you a veteran?\",\"Check off all the Boston neighborhoods you are willing to live in. Since these units are rare, the more neighborhoods you are willing to live in helps your chances of being match to a unit. \"\n"
  end
end