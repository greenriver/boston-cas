FactoryGirl.define do
  factory :building do
    sequence(:name) { |i| "#{Faker::Team.name}#{i}" }
  end
end
