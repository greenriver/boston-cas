FactoryBot.define do
  factory :match_decisions_hsa_accepts_client, class: 'MatchDecisions::ProviderOnly::HsaAcceptsClient' do
    status { :declined }
    association :decline_reason, factory: :hsa_decline_reason
  end
end