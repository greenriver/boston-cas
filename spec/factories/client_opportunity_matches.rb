FactoryBot.define do
  factory :client_opportunity_match do
    client
    opportunity
    closed { false }
    active { true }
  end
end
