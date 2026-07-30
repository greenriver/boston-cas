###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

FactoryBot.define do
  factory :match_decision_reason_assignment do
    association :route, factory: :default_route
    association :match_decision_reason
    kind { 'decline' }
    sequence(:decision_type) { |n| "MatchDecisions::FakeStep#{n}" }
    position { 0 }
  end
end
