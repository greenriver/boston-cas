class FundingSource < ActiveRecord::Base
  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include InheritsRequirementsFromServicesOnly
  include HasRequirements
  include ManagesServices

  has_many :funding_source_services, inverse_of: :funding_source
  has_many :services, through: :funding_source_services

  acts_as_paranoid
  has_paper_trail

  def self.text_search(text)
    return none unless text.present?
    query = "%#{text}%"
    where(
      arel_table[:name].matches(query)
    )
  end

  def self.associations_adding_requirements
    [:services]
  end
end
