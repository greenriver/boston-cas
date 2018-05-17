FactoryGirl.define do
  factory :match_decisions_match_recommendation_shelter_agency, class: 'MatchDecisions::MatchRecommendationShelterAgency' do
    association :match, factory: :client_opportunity_match
    status nil

    trait :not_working_with_client do
      status 'not_working_with_client'
    end

    trait :acknowledged do
      status 'acknowledged'
    end
    
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
    
    trait :shelter_expiration do
      shelter_expiration Date.tomorrow
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
    
    
    # type 'MatchDecisions::MatchRecommendationShelterAgency'
    # contact_id 5
    # client_last_seen_date
    # client_move_in_date
    # decline_reason_id
    # decline_reason_other_explanation
    # not_working_with_client_reason_id
    # not_working_with_client_reason_other_explanation
    # client_spoken_with_service_agency
    # cori_release_form_submitted
    # administrative_cancel_reason_id
  end
end