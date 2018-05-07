FactoryGirl.define do
  factory :contact, class: 'Contact' do
    sequence(:email) {|n| "user_#{n}@example.com" }
  end
end
