###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

FactoryBot.define do
  factory :hsa_decline_reason, class: 'MatchDecisionReasons::Base' do
    name { 'Ineligible for Housing Program' }
    active { true }
    ineligible_in_warehouse { true }
  end
end
