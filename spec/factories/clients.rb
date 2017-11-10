FactoryGirl.define do
  factory :client, class: 'Client' do
    ssn Faker::Number.number(9)
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    available true
    available_candidate true
    gender_id 0 # female
    date_of_birth '1990-01-01'
  end
end
