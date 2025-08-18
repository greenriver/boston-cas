###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::Occupancy < Rule
  def description
    'Matches clients who have indicated a minimum required occupancy less than or equal to the specified value.  This is sometimes calculated base on household composition and other times based on an assessment.'
  end

  def variable_requirement?
    true
  end

  def available_occupancy
    [
      [1, 'One'],
      [2, 'Two'],
      [3, 'Three'],
      [4, 'Four'],
      [5, 'Five'],
      [6, 'Six'],
      [7, 'Seven'],
      [8, 'Eight'],
      [9, 'Nine'],
      [10, 'Ten'],
    ]
  end

  def display_for_variable value
    available_occupancy.to_h.try(:[], value.to_i) || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.required_minimum_occupancy missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:required_minimum_occupancy.to_s)

    if requirement.positive
      scope.where(c_t[:required_minimum_occupancy].lteq(requirement.variable))
    else
      scope.where(c_t[:required_minimum_occupancy].gt(requirement.variable))
    end
  end
end
