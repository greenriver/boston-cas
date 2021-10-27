FactoryBot.define do
  factory :client, class: 'Client' do
    ssn { Faker::Number.number(digits: 9) }
    first_name { 'Client' }
    last_name { 'Last' }
    available { true }
    gender_id { 0 } # female
    date_of_birth { '1990-01-01' }
    sequence(:vispdat_score) { |n| Faker::Number.between(from: 1, to: 20) }
    sequence(:assessment_score) { |n| Faker::Number.between(from: 1, to: 20) }
    sequence(:vispdat_priority_score) { |n| Faker::Number.between(from: 1, to: 800) }
    sequence(:calculated_first_homeless_night) { |n| Faker::Date.between(from: 20.years.ago, to: 1.years.ago) }
    income_total_monthly { 100 }
    sequence(:days_homeless) {|n| Faker::Number.between(from: 0, to: 2000) }
    sequence(:days_homeless_in_last_three_years)  { |n| Faker::Number.between(from: 0, to: 1000) }
    sequence(:rrh_assessment_collected_at) { |n| Faker::Date.between(from: 1.years.ago, to: Date.yesterday) }
    sequence(:entry_date) { |n| Faker::Date.between(from: 1.years.ago, to: Date.yesterday) }
    sequence(:financial_assistance_end_date) { |n| Faker::Date.between(from: 1.years.ago, to: Date.yesterday) }

    disability_verified_on { nil }
  end
end
