FactoryGirl.define do
  factory :unit do
    sequence(:name) { |i| "#{Faker::Team.name}#{i}" }
    building
    ground_floor false
    wheelchair_accessible false
    occupancy 1
    household_with_children false
    number_of_bedrooms 1
    target_population "Youth"
  end
end
