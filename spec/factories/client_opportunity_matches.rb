FactoryBot.define do
  factory :client_opportunity_match do
    client
    opportunity
    closed { false }
    active { true }
    match_route { MatchRoutes::Default.first }
  end

  factory :successful_client_opportunity_match, class: 'ClientOpportunityMatch' do
    opportunity
    # association :match_recommendation_dnd_staff_decision, factory: :match_decisions_match_recommendation_dnd_staff
    closed { true }
    active { false }
    match_route { MatchRoutes::ProviderOnly.first }
  end

  factory :unsuccessful_client_opportunity_match, class: 'ClientOpportunityMatch' do
    opportunity
    # association :hsa_accepts_client_decision, factory: :match_decisions_hsa_accepts_client, status: :declined
    closed { true }
    active { false }
    match_route { MatchRoutes::ProviderOnly.first }
  end
end
