FactoryGirl.define do
  factory :female, class: 'Rules::Female' do
    name 'Female'
    verb 'be'
  end
  factory :eighteen_plus, class: 'Rules::AgeGreaterThanEightteen' do
    name 'Age greater than 18'
    verb 'be'
  end
end
