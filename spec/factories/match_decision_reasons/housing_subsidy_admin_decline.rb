###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

FactoryBot.define do
  factory :hsa_decline_reason, class: 'MatchDecisionReasons::HousingSubsidyAdminDecline' do
    name { 'Ineligible for Housing Program' }
    type { 'MatchDecisionReasons::HousingSubsidyAdminDecline' }
    active { true }
    ineligible_in_warehouse { true }
  end
end