###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::AgeGreaterThanY < Rule
  def description
    'Matches clients who are the specified age or older.'
  end

  def variable_requirement?
    true
  end

  def display_for_variable(value)
    value.to_i
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.date_of_birth missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:date_of_birth.to_s)

    years_ago = Date.current - requirement.variable.to_i.years
    if requirement.positive
      scope.where(c_t[:date_of_birth].lteq(years_ago))
    else
      scope.where(c_t[:date_of_birth].gt(years_ago))
    end
  end
end
