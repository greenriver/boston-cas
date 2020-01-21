FactoryBot.define do
  factory :match_decisions_match_recommendation_hsa_housing_date, class: 'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator' do
    association :match, factory: :client_opportunity_match
    status nil

    trait :accepted do
      status 'accepted'
    end

    trait :declined do
      status 'declined'
    end

    trait :pending do
      status 'pending'
    end

    trait :canceled do
      status 'canceled'
    end

    trait :parked do
      prevent_matching_until Date.tomorrow
    end

    trait :cancel_reason do
      administrative_cancel_reason_id 21
    end

    trait :cancel_reason_absent do
      administrative_cancel_reason_id nil
    end

    trait :decline_reason do
      decline_reason_id 12
    end

  end
end