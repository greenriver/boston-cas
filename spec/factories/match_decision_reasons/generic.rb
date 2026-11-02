###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

FactoryBot.define do
  factory :match_decision_reason, class: 'MatchDecisionReasons::Base' do
    sequence(:name) { |n| "Reason #{n}" }
    active { true }
  end
end
