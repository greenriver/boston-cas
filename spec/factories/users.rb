FactoryBot.define do
  factory :user, class: 'User' do
    first_name { 'User' }
    last_name { 'One' }
    sequence(:email) {|n| "user_#{n}@example.com" }
    password { Digest::SHA256.hexdigest('abcd1234abcd') }
    password_confirmation { Digest::SHA256.hexdigest('abcd1234abcd') }
    email_schedule { 'immediate' }
    confirmed_at { Date.yesterday }
    contact
  end
  factory :user_two, class: 'User' do
    first_name { 'User' }
    last_name { 'Two' }
    email { 'user_two@example.com' }
    password { Digest::SHA256.hexdigest('abcd1234abcd') }
    password_confirmation { Digest::SHA256.hexdigest('abcd1234abcd') }
    email_schedule { 'immediate' }
    confirmed_at { Date.yesterday }
    contact
  end
  factory :user_three, class: 'User' do
    first_name { 'User' }
    last_name { 'Three' }
    email { 'user_three@example.com' }
    password { Digest::SHA256.hexdigest('abcd1234abcd') }
    password_confirmation { Digest::SHA256.hexdigest('abcd1234abcd') }
    email_schedule { 'immediate' }
    confirmed_at { Date.yesterday }
    contact
  end
  factory :user_four, class: 'User' do
    first_name { 'User' }
    last_name { 'Four' }
    email { 'user_four@example.com' }
    password { Digest::SHA256.hexdigest('abcd1234abcd') }
    password_confirmation { Digest::SHA256.hexdigest('abcd1234abcd') }
    email_schedule { 'immediate' }
    confirmed_at { Date.yesterday }
    contact
  end

end
