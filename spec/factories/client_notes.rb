FactoryGirl.define do
  factory :client_note do
    client
    user
    note "This is a note!"
  end
end
