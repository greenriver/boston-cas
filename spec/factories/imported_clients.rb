# frozen_string_literal: true

FactoryBot.define do
  factory :imported_client do
    first_name { 'Imported' }
    sequence(:last_name) { |n| "Client#{n}" }
    sequence(:email) { |n| "imported_client_#{n}@example.com" }
    association :agency, optional: true # Allow agency to be nil or set

    # Traits for specific scenarios if needed, e.g., for warehouse_assessment? logic
    # trait :with_warehouse_details do
    #   warehouse_client_id { SecureRandom.uuid }
    #   # further associations/attributes for warehouse_assessment? to be true
    # end
  end
end
