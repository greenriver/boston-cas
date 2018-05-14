class SubProgram < ActiveRecord::Base
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

  has_many :vouchers
  has_many :file_tags
  has_one :match_route, through: :program

  accepts_nested_attributes_for :program, :vouchers
  accepts_nested_attributes_for :file_tags, allow_destroy: true
  attr_accessor :add_vouchers

  validates_presence_of :building, if: :has_buildings?

  scope :has_buildings, -> {where(program_type: SubProgram.have_buildings)}

  scope :on_route, -> (route) do
    joins(:program).merge(Program.on_route(route))
  end

  def self.types
    [
      {value: 'Project-Based', label: 'Project-Based', building: true},
      {value: 'Tenant-Based', label: 'Tenant-Based', building: false},
      {value: 'Sponsor-Based', label: 'Sponsor-Based (mobile)', building: false},
      {value: 'Sponsor-Based-With-Site', label: 'Sponsor-Based (at a site)', building: true},
    ]
  end

  def program_type_label
    SubProgram.types.select{|m| m[:value] == program_type}.first[:label]
  end

  def update_summary!
    update_matched
    update_in_progress
    update_vacancies
    self.save
  end
  # returns a useful array of types that have buildings attached
  def self.have_buildings
    b = []
    types.select{|sp| sp[:building] == true}.each do |sp|
      b << sp[:value]
    end
    b
  end

  def has_buildings?
    SubProgram.have_buildings.include? program_type
  end

  # The following methods are for populating the index page
  def site
    if building.blank?
      return 'Scattered Sites'
    else
      return building.name
    end
  end
  # which organizations are involved hint: subgrantee (service provider) + sub-contractor
  def organizations
    [].tap do |result|
      result << service_provider_name if service_provider_name.present?
      result << sub_contractor_name if sub_contractor_name.present?
    end
  end

  def self.text_search(text)
    return none unless text.present?

    program_matches = Program.where(
      Program.arel_table[:id].eq arel_table[:program_id]
    ).text_search(text).exists

    building_matches = Building.where(
      Building.arel_table[:id].eq arel_table[:building_id]
    ).text_search(text).exists

    subgrantee_matches = Subgrantee.where(
      Subgrantee.arel_table[:id].eq arel_table[:subgrantee_id]
    ).text_search(text).exists

    query = "%#{text}%"
    where(
      arel_table[:name].matches(query)
      .or(program_matches)
      .or(building_matches)
      .or(subgrantee_matches)
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
    preload(service_provider: {requirements: :rule, services: {requirements: :rule}})
    .preload(sub_contractor: {requirements: :rule, services: {requirements: :rule}})
    .preload(building: {requirements: :rule, services: {requirements: :rule}})
    .preload(program: {
      requirements: :rule,
      services: {requirements: :rule},
      funding_source: { requirements: :rule, services: {requirements: :rule} }
    })
  end

  def self.associations_adding_requirements
    [:program, :service_provider, :sub_contractor]
  end

  def self.associations_adding_services
    [:program, :service_provider, :sub_contractor]
  end

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
      #v.object.status_match.overall_status[:name]
    end

    def update_vacancies
      self[:vacancies] = vouchers.where(available: true).count
    end

end
