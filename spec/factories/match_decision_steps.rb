###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

FactoryBot.define do
  factory :match_decision_step do
    association :route, factory: :default_route
    sequence(:decision_type) { |n| "MatchDecisions::FakeStep#{n}" }
  end
end
