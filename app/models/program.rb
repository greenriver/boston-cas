class Program < ActiveRecord::Base

  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include HasRequirements
  include InheritsRequirementsFromServices
  include ManagesServices
  include MatchArchive

  belongs_to :funding_source
  delegate :name, to: :funding_source, allow_nil: true, prefix: true
  
  has_many :sub_programs, inverse_of: :program, dependent: :destroy

  has_many :program_services, inverse_of: :program
  has_many :services, through: :program_services

  ######################
  # Contact Associations
  ######################
  has_many :program_contacts
  has_many :contacts, through: :program_contacts
  has_many :housing_subsidy_admin_contacts,
    -> { where program_contacts: {housing_subsidy_admin: true} },
    class_name: Contact.name,
    through: :program_contacts,
    source: :contact
  has_many :dnd_contacts,
    -> { where program_contacts: {dnd_staff: true} },
    class_name: Contact.name,
    through: :program_contacts,
    source: :contact
  has_many :client_contacts,
    -> { where program_contacts: {client: true} },
    class_name: Contact.name,
    through: :program_contacts,
    source: :contact
  has_many :shelter_agency_contacts,
    -> { where program_contacts: {shelter_agency: true} },
    class_name: Contact.name,
    through: :program_contacts,
    source: :contact
  has_many :ssp_contacts,
    -> { where program_contacts: {ssp: true} },
    class_name: Contact.name,
    through: :program_contacts,
    source: :contact
  has_many :hsp_contacts,
    -> { where program_contacts: {hsp: true} },
    class_name: Contact.name,
    through: :program_contacts,
    source: :contact

  def default_match_contacts
    @default_match_contacts ||= ProgramContacts.new program: self
  end

  belongs_to :match_route, class_name: MatchRoutes::Base.name

  scope :on_route, -> (route) do
    joins(:match_route).merge(MatchRoutes::Base.where(type: route.class.name))
  end

  validates_presence_of :name, :match_route_id
  accepts_nested_attributes_for :sub_programs

  acts_as_paranoid
  has_paper_trail

  def sites
    s = []
    sub_programs.each do |sp|
      if sp.building == nil
        s << 'Scattered Sites'
      else
        s << sp.building.name
      end
    end
    s
  end
  def organizations
    s = []
    sub_programs.each do |sp|
      s << sp.service_provider.name if sp.service_provider.present?
      s << sp.sub_contractor.name if sp.sub_contractor.present?
    end
    s
  end

  def match_route_fixed?
    sub_programs.joins(:vouchers).exists?
  end

  def self.text_search(text)
    return none unless text.present?

    funding_source_matches = FundingSource.where(
      FundingSource.arel_table[:id].eq arel_table[:funding_source_id]
    ).text_search(text).exists

    query = "%#{text}%"
    where(
      arel_table[:name].matches(query)
      .or(funding_source_matches)
    )
  end
  
  def inherited_requirements_by_source
    inherited_service_requirements_by_source
      .merge! inherited_funding_source_requirements_by_source
  end
  
  def self.preload_inherited_requirements
    preload(
        services: {requirements: :rule},
        funding_source: { requirements: :rule, services: {requirements: :rule} },
        subgrantee: { requirements: :rule, services: {requirements: :rule} }
      )
  end

  def self.associations_adding_requirements
    [:funding_source, :services]
  end

  def self.associations_adding_services
    [:funding_source]
  end
  
  private
    def inherited_funding_source_requirements_by_source
      {}.tap do |result|
        if funding_source.present?
          result.merge! funding_source.inherited_requirements_by_source
          result[funding_source] = []
          funding_source.requirements.each do |requirement|
            result[funding_source] << requirement
          end
        end
      end
    end
      
end
