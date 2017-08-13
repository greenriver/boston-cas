FactoryGirl.define do
  factory :user do
    first_name 'Peter'
    last_name 'Clark'
    email 'peter@greenriver.com'
    password 'abcd1234'
    password_confirmation 'abcd1234'
    confirmed_at Date.yesterday
  end
end
