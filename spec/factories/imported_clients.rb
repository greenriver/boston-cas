# frozen_string_literal: true

FactoryBot.define do
  factory :imported_client do
    first_name { 'Imported' }
    sequence(:last_name) { |n| "Client#{n}" }
    sequence(:email) { |n| "imported_client_#{n}@example.com" }
    association :agency, optional: true # Allow agency to be nil or set
  end
end
