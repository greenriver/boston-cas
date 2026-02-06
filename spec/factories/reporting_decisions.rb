###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

FactoryBot.define do
  factory :reporting_decision, class: 'Reporting::Decisions' do
    association :match, factory: :client_opportunity_match

    transient do
      decision_type { 'MatchDecisions::MatchRecommendationDndStaff' }
    end

    decision_id do
      match.match_recommendation_dnd_staff_decision&.id || match.decisions.create!(
        type: decision_type,
      ).id
    end

    decision_order { 1 }
    match_step { 'Step 1' }
    decision_status { 'pending' }
    elapsed_days { 0 }
    program_name { match.program&.name || 'Test Program' }
    sub_program_name { match.sub_program&.name || 'Test Sub Program' }
    match_route { match.match_route.title }
    cas_client_id { match.client.id }
    vacancy_id { match.opportunity.id }
    match_started_at { Time.current }
  end
end
