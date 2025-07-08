###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::BedroomExact < Rule
  def description
    'Matches clients who require the exact number of bedrooms specified in "Minimum number of bedrooms required" as indicated on an assessment.'
  end

  def variable_requirement?
    true
  end

  def available_number_of_bedrooms
    [
      [1, 'One'],
      [2, 'Two'],
      [3, 'Three'],
      [4, 'Four'],
      [5, 'Five'],
    ]
  end

  def display_for_variable value
    available_number_of_bedrooms.to_h.try(:[], value.to_i) || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.required_number_of_bedrooms missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:required_number_of_bedrooms.to_s)

    if requirement.positive
      scope.where(c_t[:required_number_of_bedrooms].eq(requirement.variable))
    else
      scope.where(c_t[:required_number_of_bedrooms].not_eq(requirement.variable))
    end
  end
end
