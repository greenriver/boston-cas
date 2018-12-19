FactoryGirl.define do
  factory :non_hmis_client do
    client_identifier Faker::Number.number(4)
    first_name { "Anonymous - #{client_identifier}" }
    last_name  { "Anonymous - #{client_identifier}" }
  
  end
end
