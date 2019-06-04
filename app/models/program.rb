###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Program < ActiveRecord::Base

  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include HasRequirements
  include InheritsRequirementsFromServices
  include ManagesServices
  include MatchArchive
  include ControlledVisibility

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
  has_many :dnd_staff_contacts,
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
  has_many :do_contacts,
    -> { where program_contacts: {do: true} },
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

  def visible_by? user
    user.can_view_programs || (user.can_view_assigned_programs && super )
  end

  def editable_by? user
    user.can_edit_programs || (user.can_edit_assigned_programs && super )
  end

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

  def self.sort_options
    [
      {title: 'Program A-Z', column: 'program_id', direction: 'asc', order: 'LOWER(programs.name) ASC', visible: true},
      {title: 'Program Z-A', column: 'program_id', direction: 'desc', order: 'LOWER(programs.name) DESC', visible: true},
      {title: 'Sub-Program A-Z', column: 'sub_program_id', direction: 'asc', order: 'LOWER(sub_programs.name) ASC', visible: true},
      {title: 'Sub-Program Z-A', column: 'sub_program_id', direction: 'desc', order: 'LOWER(sub_programs.name) DESC', visible: true},
      {title: 'Building A-Z', column: 'building_id', direction: 'asc', order: 'LOWER(buildings.name) ASC', visible: true},
      {title: 'Building Z-A', column: 'building_id', direction: 'desc', order: 'LOWER(buildings.name) DESC', visible: true},
    ]
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
