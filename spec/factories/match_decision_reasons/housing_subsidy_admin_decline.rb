###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

FactoryBot.define do
  factory :hsa_decline_reason, class: 'MatchDecisionReasons::Base' do
    name { 'Ineligible for Housing Program' }
    active { true }
    ineligible_in_warehouse { true }
  end
end
