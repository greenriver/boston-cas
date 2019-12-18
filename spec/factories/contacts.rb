FactoryBot.define do
  factory :contact, class: 'Contact' do
    sequence(:first_name) { |n| "First_#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }
    sequence(:email) { |n| "user_#{n}@example.com" }
  end

  factory :macbeth, class: 'Contact' do
    first_name { 'William' }
    last_name { 'Shakespeare' }
    email { 'macbeth@scotland.gov.uk' }
  end
end
