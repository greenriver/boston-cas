###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

FactoryBot.define do
  factory :housing_attribute do
    trait :with_value do
      name { 'Furniture' }
      value { 'Furnished' }
      include_value { true }
    end

    trait :without_value do
      name { 'Dishwasher' }
      value { nil }
      include_value { false }
    end
  end
end
