###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

FactoryBot.define do
  factory :data_source do
    trait :deidentified do
      name { 'Deidentified Clients' }
      db_identifier { 'Deidentified' }
    end

    trait :warehouse do
      name { 'HMIS Warehouse' }
      db_identifier { 'Warehouse' }
    end
  end
end
