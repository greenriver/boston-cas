FactoryGirl.define do
  factory :client, class: 'Client' do
    ssn Faker::Number.number(9)
    first_name 'Client'
    last_name 'Last'
    available true
    available_candidate true
    gender_id 0 # female
    date_of_birth '1990-01-01'
    vispdat_score Faker::Number.between(1, 20)
    vispdat_priority_score Faker::Number.between(1, 800)
    calculated_first_homeless_night Faker::Date.between(20.years.ago, 1.years.ago)
  end
end
