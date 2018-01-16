FactoryGirl.define do
  factory :female, class: 'Rules::Female' do
    name 'Female'
    verb 'be'
  end
  factory :eighteen_plus, class: 'Rules::AgeGreaterThanEightteen' do
    name 'Age greater than 18'
    verb 'be'
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
