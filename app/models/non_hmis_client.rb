###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

require 'memoist'
class NonHmisClient < ApplicationRecord
  class_attribute :skip_build_assessment_if_missing
  after_initialize :build_assessment_if_missing

  has_one :project_client, -> do
    where(data_source_id: NonHmisClient.data_source.id)
  end, foreign_key: :id_in_data_source, required: false
  has_one :client, through: :project_client, required: false
  has_many :client_opportunity_matches, through: :client
  has_many :non_hmis_assessments
  has_many :shelter_histories

  belongs_to :agency
  belongs_to :contact

  has_paper_trail
  acts_as_paranoid

  scope :available, -> do
    where(available: true)
  end

  scope :visible_to, ->(user) do
    if user.can_edit_all_clients?
      all
    elsif user.can_view_all_covid_pathways?
      covid_ids = where(id: NonHmisAssessment.limitable_pathways.select(:non_hmis_client_id)).pluck(:id)
      agency_associated_ids = where(
        arel_table[:agency_id].eq(nil).
        or(arel_table[:agency_id].eq(user.agency.id)),
      ).pluck(:id)

      where(id: covid_ids + agency_associated_ids)
    else
      where(
        arel_table[:agency_id].eq(nil).
        or(arel_table[:agency_id].eq(user.agency.id)),
      )
    end
  end

  scope :editable_by, ->(user) do
    if user.can_edit_all_clients?
      all
    else
      return none unless user.can_manage_identified_clients? || user.can_enter_identified_clients?

      if pathways_enabled?
        all
      else
        where(agency_id: user.agency.id)
      end
    end
  end

  scope :identified, -> do
    where(identified: true)
  end

  scope :deidentified, -> do
    where(identified: false)
  end

  scope :family_member, ->(status) do
    joins(:non_hmis_assessments).
      where(family_member: status).
      distinct
  end

  scope :warehouse_attached, -> do
    where.not(warehouse_client_id: nil)
  end

  def self.data_source
    return DataSource.non_hmis.first if Rails.env.test? # in the test environment this data source id drifts

    @data_source ||= DataSource.non_hmis.first
  end

  # NOTE: RuboCop would like us to use attr_writer, but it doesn't seem to set @current_assessment
  # correctly, so we'll do it manually so it can interact with current_assessment correctly.
  def current_assessment=(assessment) # rubocop:disable Style/TrivialAccessors
    @current_assessment = assessment
  end

  def current_assessment
    @current_assessment ||= begin
      a_t = NonHmisAssessment.arel_table
      sort_string = Arel.sql(a_t[:entry_date].desc.to_sql + ' NULLS LAST, ' + a_t[:updated_at].desc.to_sql)
      NonHmisAssessment.where(non_hmis_client_id: id).
        order(sort_string).first ||
        client_assessments.build
    end
  end

  def current_covid_assessment
    NonHmisAssessment.where(
      non_hmis_client_id: id,
      type: NonHmisAssessment.limited_assessment_types,
    ).order(created_at: :desc).first
  end

  def self.age date:, dob:
    return unless date.present? && dob.present?

    age = date.year - dob.year
    age -= 1 if dob > date.years_ago(age)
    return age
  end

  def age date = Date.current
    return unless date_of_birth.present?

    date = date.to_date
    dob = date_of_birth.to_date
    self.class.age(date: date, dob: dob)
  end
  alias age_on age

  def full_name
    "#{first_name} #{middle_name} #{last_name}"
  end

  def self.pathways_enabled?
    assessment_type.include?('Pathways')
  end

  def pathways_enabled?
    self.class.pathways_enabled?
  end

  def involved_in_match?
    client_opportunity_matches.exists?
  end

  def available_availabilities
    [['Active', true], ['Inactive', false]].freeze
  end

  def cohort_names
    return '' unless Warehouse::Base.enabled?

    Warehouse::Cohort.active.where(id: active_cohort_ids).pluck(:name).join("\n")
  end

  # Sorting and Searching
  scope :search_first_name, ->(name) do
    arel_table[:first_name].lower.matches("#{name.downcase}%")
  end

  scope :search_last_name, ->(name) do
    arel_table[:last_name].lower.matches("#{name.downcase}%")
  end

  scope :search_alternate_name, ->(name) do
    arel_table[:client_identifier].lower.matches("%#{name.downcase}%")
  end

  def self.ransackable_scopes(_auth_object = nil)
    [:text_search]
  end

  def self.possible_agencies
    Agency.order(:name).pluck(:name)
  end

  def self.possible_cohorts
    return [] unless Warehouse::Base.enabled?

    Warehouse::Cohort.active.visible_in_cas.pluck(:id, :name).to_h
  end

  def populate_project_client(project_client)
    set_project_client_fields(project_client)
  end

  private def set_project_client_fields(project_client) # rubocop:disable Naming/AccessorMethodName, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
    # NonHmisClient fields
    project_client.data_source_id = self.class.data_source.id
    project_client.id_in_data_source = id
    project_client.first_name = fix_first_name
    project_client.last_name = fix_last_name
    project_client.non_hmis_client_identifier = client_identifier
    project_client.active_cohort_ids = active_cohort_ids
    project_client.date_of_birth = date_of_birth
    project_client.ssn = ssn
    project_client.middle_name = middle_name
    project_client.gender = gender
    project_client.email = email.presence || current_assessment&.email_addresses
    project_client.address = current_assessment&.mailing_address
    project_client.housing_release_status = _('Full HAN Release') if full_release_on_file
    project_client.housing_release_status = _('Limited CAS Release') if limited_release_on_file
    project_client.tags = cas_tags
    project_client.default_shelter_agency_contacts = [contact&.email] if contact_id.present?
    project_client.sync_with_cas = available

    # current_assessment fields
    project_client.assessment_name = current_assessment&.for_matching&.keys&.first
    project_client.assessment_score = current_assessment&.assessment_score || 0
    project_client.days_homeless_in_last_three_years = current_assessment&.total_days_homeless_in_the_last_three_years || 0
    project_client.days_literally_homeless_in_last_three_years = current_assessment&.total_days_homeless_in_the_last_three_years || 0
    project_client.days_homeless = current_assessment&.days_homeless || current_assessment&.total_days_homeless_in_the_last_three_years || 0
    project_client.hmis_days_homeless_last_three_years = current_assessment&.days_homeless_in_the_last_three_years
    project_client.date_days_homeless_verified = current_assessment&.date_days_homeless_verified
    project_client.who_verified_days_homeless = current_assessment&.who_verified_days_homeless
    project_client.entry_date = current_assessment&.entry_date
    project_client.rrh_assessment_collected_at = current_assessment&.entry_date
    project_client.financial_assistance_end_date = current_assessment&.financial_assistance_end_date
    project_client.tie_breaker_date = current_assessment&.tie_breaker_date

    if current_assessment&.actively_homeless
      project_client.calculated_last_homeless_night = Date.current
    else
      project_client.calculated_last_homeless_night = nil
    end

    project_client.cellphone = current_assessment&.phone_number
    project_client.case_manager_contact_info = current_assessment&.case_manager_contact_info

    if current_assessment&.veteran_status.present?
      project_client.veteran_status = 1 if current_assessment&.veteran_status == 'Yes'
    elsif current_assessment&.veteran
      project_client.veteran_status = 1
    end
    project_client.rrh_desired = current_assessment&.rrh_desired || false
    project_client.youth_rrh_desired = current_assessment&.youth_rrh_desired || false
    project_client.rrh_assessment_contact_info = current_assessment&.rrh_assessment_contact_info
    project_client.required_number_of_bedrooms = current_assessment&.required_number_of_bedrooms || 1
    project_client.required_minimum_occupancy = current_assessment&.required_minimum_occupancy || 1
    project_client.requires_wheelchair_accessibility = current_assessment&.requires_wheelchair_accessibility || false
    project_client.requires_elevator_access = current_assessment&.requires_elevator_access || false
    family = current_assessment&.family_member || current_assessment&.household_size.present? && current_assessment.household_size > 1 || false
    project_client.family_member = family

    project_client.calculated_chronic_homelessness = current_assessment&.calculated_chronic_homelessness || false
    project_client.neighborhood_interests = current_assessment&.neighborhood_interests || []
    project_client.interested_in_set_asides = current_assessment&.interested_in_set_asides || false

    monthly_income = current_assessment&.income_total_monthly
    monthly_income = current_assessment.income_total_annual / 12 if monthly_income.blank? && current_assessment&.income_total_annual.present?
    project_client.income_total_monthly = monthly_income
    project_client.disabling_condition = (1 if current_assessment&.documented_disability) || (1 if current_assessment&.disabling_condition)
    project_client.physical_disability = (1 if current_assessment&.physical_disability)
    project_client.developmental_disability = (1 if current_assessment&.developmental_disability)
    project_client.domestic_violence = 1 if current_assessment&.domestic_violence || identified == false

    project_client.chronic_health_condition = (1 if current_assessment&.chronic_health_condition)
    project_client.mental_health_problem = (1 if current_assessment&.mental_health_problem)
    project_client.substance_abuse_problem = if current_assessment&.substance_abuse_problem then 'Yes' else 'No' end
    project_client.vispdat_score = current_assessment&.vispdat_score
    project_client.vispdat_priority_score = current_assessment&.vispdat_priority_score
    project_client.health_prioritized = current_assessment&.health_prioritized
    project_client.hiv_positive = current_assessment&.hiv_aids || hiv_aids
    project_client.is_currently_youth = current_assessment&.is_currently_youth || false
    project_client.older_than_65 = current_assessment&.older_than_65
    # assessor info
    assessor = current_assessment&.user&.contact
    project_client.assessor_first_name = assessor&.first_name
    project_client.assessor_last_name = assessor&.last_name
    project_client.assessor_email = assessor&.email
    project_client.assessor_phone = assessor&.phone
    # Pathways
    project_client.income_maximization_assistance_requested = current_assessment&.income_maximization_assistance_requested
    project_client.pending_subsidized_housing_placement = current_assessment&.pending_subsidized_housing_placement
    project_client.rrh_th_desired = current_assessment&.rrh_th_desired
    project_client.dv_rrh_desired = current_assessment&.dv_rrh_desired
    project_client.sro_ok = current_assessment&.sro_ok
    project_client.evicted = current_assessment&.evicted
    project_client.ssvf_eligible = current_assessment&.ssvf_eligible || false
    project_client.holds_voucher_on = nil # reset to nil
    project_client.holds_voucher_on = current_assessment&.entry_date if current_assessment&.have_tenant_voucher
    project_client.enrolled_in_es = current_assessment&.enrolled_in_es || false
    project_client.enrolled_in_so = current_assessment&.enrolled_in_so || false
    # as of 3/21/2022 Set majority_sheltered based on CLS response
    # possible responses are all sheltered except "Unsheltered"
    project_client.majority_sheltered = current_assessment&.setting != 'Unsheltered'
    project_client.strengths = current_assessment&.strengths&.reject(&:blank?)
    project_client.challenges = current_assessment&.challenges&.reject(&:blank?)
    project_client.open_case = current_assessment&.tc_hat_client_history&.include?('open_case')
    project_client.housing_for_formerly_homeless = current_assessment&.housing_preferences&.include?('with_formerly_homeless')

    [
      :foster_care,
      :drug_test,
      :heavy_drug_use,
      :sober,
      :willing_case_management,
      :employed_three_months,
      :living_wage,
      :need_daily_assistance,

      :full_time_employed,
      :can_work_full_time,
      :willing_to_work_full_time,
      :rrh_successful_exit,
      :lifetime_sex_offender,
      :th_desired,
      :drug_test,
      :employed_three_months,
      :site_case_management_required,
      :currently_fleeing,
      :dv_date,
      :pregnancy_status,
    ].each do |method|
      project_client[method] = current_assessment&.send(method)
    end
    project_client.needs_update = true
    project_client
  end

  private def fix_first_name
    first_name
  end

  private def fix_last_name
    last_name
  end

  def build_assessment_if_missing
    return if self.class.skip_build_assessment_if_missing?
    return unless persisted?
    return if client_assessments.exists?

    # Do not automatically create assessment if pathways is enabled
    # user is routed to new form
    assessment_type = "#{type.tableize.singularize}_assessment"
    pathways_assessment = if Config.column_names.include?(assessment_type)
      Config.get(assessment_type).include? 'Pathways'
    else
      false
    end
    return if pathways_assessment

    update_assessment_from_client(client_assessments.build)
  end

  def update_assessment_from_client(assessment = current_assessment)
    assessment.assessment_score = assessment_score
    assessment.actively_homeless = actively_homeless
    assessment.days_homeless_in_the_last_three_years = days_homeless_in_the_last_three_years
    assessment.veteran = veteran
    assessment.rrh_desired = rrh_desired
    assessment.youth_rrh_desired = youth_rrh_desired
    assessment.rrh_assessment_contact_info = rrh_assessment_contact_info
    assessment.income_maximization_assistance_requested = income_maximization_assistance_requested
    assessment.pending_subsidized_housing_placement = pending_subsidized_housing_placement
    assessment.requires_wheelchair_accessibility = requires_wheelchair_accessibility
    assessment.required_number_of_bedrooms = required_number_of_bedrooms
    assessment.required_minimum_occupancy = required_minimum_occupancy
    assessment.requires_elevator_access = requires_elevator_access
    assessment.family_member = family_member
    assessment.calculated_chronic_homelessness = calculated_chronic_homelessness
    assessment.neighborhood_interests = neighborhood_interests
    assessment.income_total_monthly = income_total_monthly
    assessment.disabling_condition = disabling_condition
    assessment.physical_disability = physical_disability
    assessment.developmental_disability = developmental_disability
    assessment.date_days_homeless_verified = date_days_homeless_verified
    assessment.who_verified_days_homeless = who_verified_days_homeless
    assessment.domestic_violence = domestic_violence
    assessment.interested_in_set_asides = interested_in_set_asides
    assessment.set_asides_housing_status = set_asides_housing_status
    assessment.set_asides_resident = set_asides_resident
    assessment.shelter_name = shelter_name
    assessment.entry_date = entry_date
    assessment.case_manager_contact_info = case_manager_contact_info
    assessment.phone_number = phone_number
    assessment.have_tenant_voucher = have_tenant_voucher
    assessment.children_info = children_info
    assessment.studio_ok = studio_ok
    assessment.one_br_ok = one_br_ok
    assessment.sro_ok = sro_ok
    assessment.fifty_five_plus = fifty_five_plus
    assessment.sixty_two_plus = sixty_two_plus
    assessment.voucher_agency = voucher_agency
    assessment.interested_in_disabled_housing = interested_in_disabled_housing
    assessment.chronic_health_condition = chronic_health_condition
    assessment.mental_health_problem = mental_health_problem
    assessment.substance_abuse_problem = substance_abuse_problem
    assessment.vispdat_score = vispdat_score
    assessment.vispdat_priority_score = vispdat_priority_score
    assessment.health_prioritized = health_prioritized
    assessment.imported_timestamp = imported_timestamp
    assessment.is_currently_youth = is_currently_youth
    assessment.older_than_65 = older_than_65
    assessment.days_homeless = days_homeless
    assessment.sixty_plus = sixty_plus
    assessment.tc_hat_household_type = 'Adults with Children' if family_member
    assessment.hiv_aids = hiv_aids
    assessment.pregnancy_status = pregnancy_status

    assessment.created_at = created_at
    assessment.updated_at = updated_at
    assessment.deleted_at = deleted_at

    assessment
  end

  def annual_income
    return 0 unless current_assessment&.income_total_monthly.present?

    current_assessment.income_total_monthly * 12
  end

  def log(message)
    Rails.logger.info message
  end

  # Memoize assessment_tags at the class, they don't change often
  # This is the syntax for class method memoization, it is equivalent to
  # @@assessment_tags, but comes with an api
  # you can bust the cache with assessment_tags(true)
  class << self
    extend Memoist
    def assessment_tags
      Tag.where(rrh_assessment_trigger: true)
    end
    memoize :assessment_tags
  end

  private def cas_tags
    @cas_tags = {}
    self.class.assessment_tags.each do |tag|
      @cas_tags[tag.id] = assessment_score if assessment_score.present?
    end
    return @cas_tags
  end

  def self.current_assessments_for(client_ids)
    a_t = NonHmisAssessment.arel_table
    sort_string = Arel.sql(a_t[:entry_date].desc.to_sql + ' NULLS LAST, ' + a_t[:updated_at].desc.to_sql)
    NonHmisAssessment.one_for_column(
      order_clause: sort_string,
      source_arel_table: NonHmisAssessment.arel_table,
      group_on: :non_hmis_client_id,
      scope: NonHmisAssessment.where(non_hmis_client_id: client_ids),
    ).index_by(&:non_hmis_client_id)
  end

  def self.project_clients_for(client_ids)
    ProjectClient.where(
      data_source_id: data_source.id,
      id_in_data_source: client_ids,
    ).index_by(&:id_in_data_source)
  end

  def update_project_clients_from_non_hmis_clients
    # prevent unneeded after_initialize hook from running queries
    NonHmisClient.skip_build_assessment_if_missing = true
    # make sure we have a recent set of assessment tags (cache bust)
    self.class.assessment_tags(true)
    # remove unused ProjectClients
    ProjectClient.where(data_source_id: self.class.data_source.id).
      where.not(id_in_data_source: NonHmisClient.select(:id)).
      delete_all
    # update or add clients
    client_scope.preload(:contact).find_in_batches do |batch|
      project_clients = self.class.project_clients_for(batch.map(&:id))
      assessments = self.class.current_assessments_for(batch.map(&:id))
      batch.each do |client|
        project_client = project_clients[client.id] || ProjectClient.new
        client.current_assessment = assessments[client.id]
        project_clients[client.id] = client.populate_project_client(project_client)
      end
      ProjectClient.import(
        project_clients.values,
        on_duplicate_key_update: {
          conflict_target: [:id],
          columns: ProjectClient.column_names.map(&:to_sym),
        },
      )
    end

    log "Updated #{client_scope.count} ProjectClients from #{self.class.name}"
  ensure
    NonHmisClient.skip_build_assessment_if_missing = false
  end

  def client_scope
    raise NotImplementedError
  end

  def self.ds_identifier
    'Deidentified' # Name is historical -- data source also includes identified clients
  end

  def download_data
    raise NotImplementedError
  end

  def download_headers
    raise NotImplementedError
  end

  def self.optional_field_names
    {
      assessment_score: 'Assessment Score',
      vispdat_score: 'VI-SPDAT Score',
      vispdat_priority_score: 'VI-SPDAT Priority Score',
      actively_homeless: 'Actively Homeless',
      health_prioritized: 'Prioritized for Health',
      hiv_aids: 'HOPWA Eligible',
    }.freeze
  end

  def self.available_youth_choices
    {
      'Youth-Specific Only: youth specific programs are with agencies who have a focus on young populations; they may be able to offer drop-in spaces for youth, as well as community-building and connections with other youth' => 'youth',
      'Adult Programs Only: Adult programs serve youth who are 18-24, but may not have built in community space or activities to connect other youth. They can help you find those opportunities. The adult RRH programs typically have more frequent openings at this time.' => 'adult',
      'Both Adult and Youth-Specific programs' => 'both',
      'Not applicable - client is not Youth' => 'no',
    }.freeze
  end

  def self.available_dv_choices
    {
      'Domestic Violence (DV) - Specific Only: these are agencies who have a focus on populations experiencing violence; they may be able to offer specialized services for survivors in-house, such as support groups, clinical services and legal services.' => 'dv',
      'Non-DV Programs Only: these are agencies that serve people fleeing violence, but may need to link you to outside, specialized agencies for specific services such as DV support groups, clinical services and legal services. The non-DV RRH programs typically have more frequent openings at this time.' => 'non-dv',
      'Both DV and Non-DV Programs' => 'both',
      'Not applicable - client is not currently fleeing domestic violence.' => nil,
    }.freeze
  end

  def self.available_evicted_choices
    {
      'Yes or Unsure' => true,
      'No' => false,
    }
  end
end
