###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Subgrantee < ApplicationRecord
  include InheritsRequirementsFromServicesOnly
  include HasRequirements
  include ManagesServices
  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include MatchArchive

  has_many :buildings
  has_many :data_sources

  has_many :subgrantee_contacts, dependent: :destroy, inverse_of: :subgrantee
  has_many :contacts, through: :subgrantee_contacts

  has_many :subgrantee_services, inverse_of: :subgrantee
  has_many :services, through: :subgrantee_services

  validates_presence_of :name

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
