FactoryGirl.define do
  factory :data_source do
    trait :deidentified do
      name 'Deidentified Clients'
      db_identifier 'Deidentified'
    end
    
    trait :warehouse do 
      name 'HMIS Warehouse'
      db_identifier 'Warehouse'
    end
  end
end
