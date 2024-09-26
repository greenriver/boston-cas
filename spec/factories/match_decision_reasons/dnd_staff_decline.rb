###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

FactoryBot.define do
  factory :dnd_staff_decline_reason, class: 'MatchDecisionReasons::Base' do
    name { 'Client won\'t be eligible for housing type' }
    active { true }
    ineligible_in_warehouse { false }
  end
end
