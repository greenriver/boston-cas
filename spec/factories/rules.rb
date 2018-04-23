FactoryGirl.define do
  factory :female, class: 'Rules::Female' do
    name 'Female'
    verb 'be'
  end
  factory :male, class: 'Rules::Male' do
    name 'Male'
    verb 'be'
  end
  factory :veteran, class: 'Rules::Veteran' do
    name 'Veteran'
    verb 'be'
  end
  factory :sixteen_plus, class: 'Rules::AgeGreaterThanSixteen' do
    name 'Age greater than 16'
    verb 'be'
  end
  factory :eighteen_plus, class: 'Rules::AgeGreaterThanEightteen' do
    name 'Age greater than 18'
    verb 'be'
  end
  factory :twenty_five_plus, class: 'Rules::AgeGreaterThanTwentyFive' do
    name 'Age greater than 25'
    verb 'be'
  end
  factory :chronic_substance_use, class: 'Rules::ChronicSubstanceUse' do
    name 'Chronic Substance Use'
    verb 'be'
  end
  factory :chronically_homeless, class: 'Rules::ChronicallyHomeless' do
    name 'Chronically Homeless'
    verb 'be'
  end
  factory :mental_health_eligible, class: 'Rules::MentalHealthEligible' do
    name 'Mental Health Eligible'
    verb 'be'
  end
  factory :homeless, class: 'Rules::Homeless' do
    name 'Homeless'
    verb 'be'
  end
  factory :mi_and_sa_co_morbid, class: 'Rules::MiAndSaCoMorbid' do
    name 'Chronically homeless, mental health, and substance abuse'
    verb 'be'
  end
  factory :physical_disability, class: 'Rules::PhysicalDisablingCondition' do
    name 'Physically disabling condition'
    verb 'have'
  end
  factory :income_less_than_50_percent_ami, class: 'Rules::IncomeLessThanFiftyPercentAmi' do 
    name 'Less than 50% Area Median Income (Very Low Income)'
    verb 'have'
  end
  factory :low_income, class: 'Rules::IncomeLessThanEightyPercentAmi' do
    name 'Less than 80% Area Median Income (Low Income)'
    verb 'have'
  end
  factory :income, class: 'Rules::Income' do
    name 'Income'
    verb 'have'
  end
  factory :last_seen, class: 'Rules::SeenInLastThirtyDays' do
    name 'Seen in Last 30 Days'
    verb 'be'
  end
  factory :vispdat_less_than_3, class: 'Rules::VispdatScoreThreeOrLess' do
    name 'VI-SPDAT score of 3 or less'
    verb 'have'
  end
  factory :vispdat_between_4_and_7, class: 'Rules::VispdatScoreFourToSeven' do
    name 'VI-SPDAT score of 4 to 7'
    verb 'have'
  end
  factory :vispdat_more_than_8, class: 'Rules::VispdatScoreEightOrMore' do
    name 'VI-SPDAT score of 8 or more'
    verb 'have'
  end
end
