FactoryBot.define do
  factory :rules_verified_disability, class: 'Rules::VerifiedDisability' do
    name { 'Verified disability' }
    type { 'Rules::VerifiedDisability' }
    verb { 'have' }
  end
end