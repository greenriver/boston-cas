FactoryGirl.define do
  factory :client, class: 'Client' do
    ssn Faker::Number.number(9)
  end
end
