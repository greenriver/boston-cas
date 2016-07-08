class Program < ActiveRecord::Base

  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include HasRequirements
  include InheritsRequirementsFromServices
  include ManagesServices

  belongs_to :funding_source
  delegate :name, to: :funding_source, allow_nil: true, prefix: true
  
  has_many :contacts
  has_many :sub_programs, inverse_of: :program, dependent: :destroy

  has_many :program_services, inverse_of: :program
  has_many :services, through: :program_services

  validates_presence_of :name
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
      unless sp.service_provider.nil?
        s << sp.service_provider.name
      end
      unless sp.sub_contractor.nil?
        s << sp.sub_contractor.name
      end
    end
    s
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
