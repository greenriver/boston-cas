###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class OpportunityContact < ActiveRecord::Base

  belongs_to :opportunity, required: true, inverse_of: :opportunity_contacts
  belongs_to :contact, required: true, inverse_of: :opportunity_contacts

  include ContactJoinModel

  acts_as_paranoid
  has_paper_trail

  scope :shelter_agency, -> {where shelter_agency: true}
  scope :housing_subsidy_admin, -> {where housing_subsidy_admin: true}
end
