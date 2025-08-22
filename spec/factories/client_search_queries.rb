# frozen_string_literal: true

FactoryBot.define do
  factory :client_search_query do
    association :created_by, factory: :user
    params { { q: 'john doe' } }
    fingerprint { ClientSearchQuery.generate_fingerprint(params) }

    trait :with_client_params do
      params do
        {
          q: 'search term',
          client: {
            first_name: 'John',
            last_name: 'Doe',
            dob: '1990-01-01',
            ssn: '123-45-6789',
          },
        }
      end
    end
  end
end
