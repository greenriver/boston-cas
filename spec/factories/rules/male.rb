FactoryBot.define do
  factory :rules_male, class: 'Rules::Male' do
    name { 'Male' }
    type { 'Rules::Male' }
    verb { 'be' }
  end
end