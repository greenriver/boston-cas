###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class SubProgram < ApplicationRecord
  acts_as_paranoid
  has_paper_trail
  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include MatchArchive

  belongs_to :program, inverse_of: :sub_programs
  belongs_to :building

  belongs_to :service_provider, class_name: 'Subgrantee', foreign_key: :subgrantee_id
  delegate :name, to: :service_provider, allow_nil: true, prefix: true

  belongs_to :sub_contractor, class_name: 'Subgrantee', foreign_key: :sub_contractor_id
  delegate :name, to: :sub_contractor, allow_nil: true, prefix: true

  belongs_to :housing_subsidy_administrator, class_name: 'Subgrantee', foreign_key: :hsa_id

  belongs_to :match_prioritization, class_name: 'MatchPrioritization::Base', foreign_key: :match_prioritization_id, primary_key: :id, optional: true

  has_many :vouchers
  has_many :file_tags
  has_one :match_route, through: :program

  accepts_nested_attributes_for :program, :vouchers
  accepts_nested_attributes_for :file_tags, allow_destroy: true
  attr_accessor :add_vouchers

  validates_presence_of :building, if: :has_buildings?

  scope :has_buildings, -> { where(program_type: SubProgram.have_buildings) }

  scope :on_route, ->(route) do
    joins(:program).merge(Program.on_route(route))
  end

  scope :open, -> do
    where(closed: false)
  end

  scope :closed, -> do
    where(closed: true)
  end

  ######################
  # Contact Associations
  ######################
  has_many :sub_program_contacts
  has_many :contacts, through: :sub_program_contacts
  has_many :housing_subsidy_admin_contacts,
           -> { where sub_program_contacts: { housing_subsidy_admin: true } },
           class_name: Contact.name,
           through: :sub_program_contacts,
           source: :contact
  has_many :dnd_staff_contacts,
           -> { where sub_program_contacts: { dnd_staff: true } },
           class_name: Contact.name,
           through: :sub_program_contacts,
           source: :contact
  has_many :client_contacts,
           -> { where sub_program_contacts: { client: true } },
           class_name: Contact.name,
           through: :sub_program_contacts,
           source: :contact
  has_many :shelter_agency_contacts,
           -> { where sub_program_contacts: { shelter_agency: true } },
           class_name: Contact.name,
           through: :sub_program_contacts,
           source: :contact
  has_many :ssp_contacts,
           -> { where sub_program_contacts: { ssp: true } },
           class_name: Contact.name,
           through: :sub_program_contacts,
           source: :contact
  has_many :hsp_contacts,
           -> { where sub_program_contacts: { hsp: true } },
           class_name: Contact.name,
           through: :sub_program_contacts,
           source: :contact
  has_many :do_contacts,
           -> { where sub_program_contacts: { do: true } },
           class_name: Contact.name,
           through: :sub_program_contacts,
           source: :contact

  def self.types
    [
      { value: 'Project-Based', label: 'Project-Based', building: true },
      { value: 'Tenant-Based', label: 'Tenant-Based', building: false },
      { value: 'Sponsor-Based', label: 'Sponsor-Based (mobile)', building: false },
      { value: 'Sponsor-Based-With-Site', label: 'Sponsor-Based (at a site)', building: true },
      { value: 'Set-Aside', label: 'Set-Aside', building: true },
      { value: 'Navigation', label: 'Navigation', building: false },
    ]
  end

  def default_match_contacts
    @default_match_contacts ||= SubProgramContacts.new sub_program: self
  end

  def name_with_status
    @name_with_status = name
    @name_with_status += ' (Closed) ' if closed?
    @name_with_status.presence || '(unnamed)'
  end

  def program_type_label
    SubProgram.types.select { |m| m[:value] == program_type }.first[:label]
  end

  def active_prioritization_scheme
    match_prioritization.presence || match_route.match_prioritization
  end

  def update_summary!
    update_matched
    update_in_progress
    update_vacancies
    save
  end

  # returns a useful array of types that have buildings attached
  def self.have_buildings # rubocop:disable Naming/PredicateName
    b = []
    types.select { |sp| sp[:building] == true }.each do |sp|
      b << sp[:value]
    end
    b
  end

  def has_buildings? # rubocop:disable Naming/PredicateName
    SubProgram.have_buildings.include?(program_type)
  end

  # The following methods are for populating the index page
  def site
    return 'Scattered Sites' if building.blank?

    building.name
  end

  # which organizations are involved hint: subgrantee (service provider) + sub-contractor
  def organizations
    [].tap do |result|
      result << service_provider_name if service_provider_name.present?
      result << sub_contractor_name if sub_contractor_name.present?
    end
  end

  def self.available_event_types
    {
      1 => 'Referral to Prevention Assistance project',
      2 => 'Problem Solving/Diversion/Rapid Resolution intervention or service',
      3 => 'Referral to scheduled Coordinated Entry Crisis Needs Assessment',
      4 => 'Referral to scheduled Coordinated Entry Housing Needs Assessment',
      5 => 'Referral to Post-placement/ follow-up case management',
      6 => 'Referral to Street Outreach project or services',
      7 => 'Referral to Housing Navigation project or services',
      8 => 'Referral to Non-continuum services: Ineligible for continuum services',
      9 => 'Referral to Non-continuum services: No availability in continuum services',
      10 => 'Referral to Emergency Shelter bed opening',
      11 => 'Referral to Transitional Housing bed/unit opening',
      12 => 'Referral to Joint TH-RRH project/unit/resource opening',
      13 => 'Referral to RRH project resource opening',
      14 => 'Referral to PSH project resource opening',
      15 => 'Referral to Other PH project resource opening',
      16 => 'Referral to emergency assistance/flex fund/furniture assistance',
      17 => 'Referral to Emergency Housing Voucher (EHV)',
      18 => 'Referral to a Housing Stability Voucher',
    }.freeze
  end

  def self.text_search(text)
    return none unless text.present?

    program_matches = Program.
      where(Program.arel_table[:id].eq arel_table[:program_id]).
      text_search(text).arel.exists

    building_matches = Building.
      where(Building.arel_table[:id].eq arel_table[:building_id]).
      text_search(text).arel.exists

    subgrantee_matches = Subgrantee.
      where(Subgrantee.arel_table[:id].eq arel_table[:subgrantee_id]).
      text_search(text).arel.exists

    query = "%#{text}%"
    where(
      arel_table[:name].matches(query).
      or(program_matches).
      or(building_matches).
      or(subgrantee_matches),
    )
  end

  def inherited_requirements_by_source
    {}
      .merge! inherited_program_requirements_by_source
      .merge! inherited_service_provider_requirements_by_source
      .merge! inherited_sub_contractor_requirements_by_source
      .merge! inherited_building_requirements_by_source
  end

  def self.preload_inherited_requirements
    preload(service_provider: { requirements: :rule, services: { requirements: :rule } }).
      preload(sub_contractor: { requirements: :rule, services: { requirements: :rule } }).
      preload(building: { requirements: :rule, services: { requirements: :rule } }).
      preload(
        program: {
          requirements: :rule,
          services: { requirements: :rule },
          funding_source: { requirements: :rule, services: { requirements: :rule } },
        },
      )
  end

  def self.associations_adding_requirements
    [:program, :service_provider, :sub_contractor]
  end

  def self.associations_adding_services
    [:program, :service_provider, :sub_contractor]
  end

  # Get visibility from the associated Program
  delegate :visible_by?, to: :program
  delegate :editable_by?, to: :program

  scope :visible_by, ->(user) {
    joins(:program).merge(Program.visible_by(user))
  }
  scope :editable_by, ->(user) {
    joins(:program).merge(Program.editable_by(user))
  }

  private

  def inherited_service_provider_requirements_by_source
    {}.tap do |result|
      if service_provider.present?
        result.merge! service_provider.inherited_requirements_by_source
        result[service_provider] = []
        service_provider.requirements.each do |requirement|
          result[service_provider] << requirement
        end
      end
    end
  end

  def inherited_program_requirements_by_source
    {}.tap do |result|
      if program.present?
        result.merge! program.inherited_requirements_by_source
        result[program] = []
        program.requirements.each do |requirement|
          result[program] << requirement
        end
      end
    end
  end

  def inherited_sub_contractor_requirements_by_source
    {}.tap do |result|
      if sub_contractor.present?
        result.merge! sub_contractor.inherited_requirements_by_source
        result[sub_contractor] = []
        sub_contractor.requirements.each do |requirement|
          result[sub_contractor] << requirement
        end
      end
    end
  end

  def inherited_building_requirements_by_source
    {}.tap do |result|
      if building.present?
        result.merge! building.inherited_requirements_by_source
        result[building] = []
        building.requirements.each do |requirement|
          result[building] << requirement
        end
      end
    end
  end

  def update_matched
    self[:matched] = 0
    vouchers.each do |v|
      self[:matched] += 1 if v.status_match.present? && v.status_match.successful?
    end
  end

  def update_in_progress
    self[:in_progress] = 0
    vouchers.each do |v|
      self[:in_progress] += 1 if v.status_match.present? && v.status_match.active?
    end
    # v.object.status_match.overall_status[:name]
  end

  def update_vacancies
    self[:vacancies] = 0
    vouchers.where(available: true).each do |v|
      self[:vacancies] += 1 if v.status_match.blank? && v.archived_at.blank?
    end
  end
end
