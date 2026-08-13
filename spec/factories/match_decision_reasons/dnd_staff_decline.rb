###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

FactoryBot.define do
  factory :dnd_staff_decline_reason, class: 'MatchDecisionReasons::Base' do
    name { 'Client won\'t be eligible for housing type' }
    active { true }
    ineligible_in_warehouse { false }
  end
end
