###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Service < ApplicationRecord
  include Matching::HasOrInheritsRequirements
  include HasRequirements
  include MatchArchive

  has_many :building_services, dependent: :destroy, inverse_of: :service
  has_many :buildings, through: :building_services

  has_many :program_services, inverse_of: :service
  has_many :programs, through: :program_serivces

  has_many :subgrantee_services, inverse_of: :service
  has_many :subgrantee, through: :subgrantee_services

  has_many :funding_source_services, inverse_of: :service
  has_many :funding_sources, through: :funding_source_services

  has_many :rules, through: :service_rules

  acts_as_paranoid
  has_paper_trail

  def inherited_requirements_by_source
    {}
  end

  def self.preload_for_inherited_requirements
    all
  end

  def requirements_description
    requirements.map(&:name).compact.join ", "
  end

end
