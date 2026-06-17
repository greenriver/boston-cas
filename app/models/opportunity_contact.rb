###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class OpportunityContact < ApplicationRecord

  belongs_to :opportunity, inverse_of: :opportunity_contacts
  belongs_to :contact, inverse_of: :opportunity_contacts

  include ContactJoinModel

  acts_as_paranoid
  has_paper_trail

  scope :shelter_agency, -> {where shelter_agency: true}
  scope :housing_subsidy_admin, -> {where housing_subsidy_admin: true}
end
