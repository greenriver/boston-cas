# frozen_string_literal: true

FactoryBot.define do
  factory :deidentified_client do
    sequence(:client_identifier) { |n| "deidentified-#{n}" }
    first_name { "Anonymous - #{client_identifier}" }
    last_name  { "Anonymous - #{client_identifier}" }
    identified { false }
  end
end
