FactoryGirl.define do
  factory :client, class: 'Client' do
    ssn Faker::Number.number(9)
    first_name 'Client'
    last_name 'Last'
    available true
    gender_id 0 # female
    date_of_birth '1990-01-01'
    sequence(:vispdat_score) {|n| Faker::Number.between(1, 20) }
    sequence(:assessment_score) {|n| Faker::Number.between(1, 20) }
    sequence(:vispdat_priority_score) { |n| Faker::Number.between(1, 800) }
    sequence(:calculated_first_homeless_night) { |n| Faker::Date.between(20.years.ago, 1.years.ago) }
    income_total_monthly 100
    sequence(:days_homeless) {|n| Faker::Number.between(0, 2000) }
    sequence(:days_homeless_in_last_three_years)  {|n| Faker::Number.between(0, 1000) }
   
  end
end
