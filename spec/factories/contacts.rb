FactoryGirl.define do
  factory :contact, class: 'Contact' do
    sequence(:first_name) {|n| "First_#{n}" }
    sequence(:last_name) {|n| "Last#{n}" }
    sequence(:email) {|n| "user_#{n}@example.com" }
  end
end
