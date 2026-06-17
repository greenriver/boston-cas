###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

FactoryBot.define do
  factory :unavailable_as_candidate_for do
    client
    match_route_type { 'MatchRoutes::Default' }
    reason { UnavailableAsCandidateFor::PARKED_TEXT }
    created_at { Time.current }

    trait :active_match do
      reason { UnavailableAsCandidateFor::ACTIVE_MATCH_TEXT }
      association :match, factory: :client_opportunity_match
    end

    trait :successful_match do
      reason { UnavailableAsCandidateFor::SUCCESSFUL_MATCH_TEXT }
      association :match, factory: :successful_client_opportunity_match
    end

    trait :with_expiration do
      expires_at { 30.days.from_now }
    end
  end
end
