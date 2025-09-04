###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::IncomeMaximum < Rule
  def description
    'Matches clients who have at most the maximum income as indicated on a HUD assessment. Or other assessment as configured in the warehouse.'
  end

  def variable_requirement?
    true
  end

  def display_for_variable value
    "$#{value} / month"
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.income_total_monthly missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:income_total_monthly.to_s)

    if requirement.positive
      where = c_t[:income_total_monthly].lteq(requirement.variable.to_i).or(c_t[:income_total_monthly].eq(nil))
    else
      where = c_t[:income_total_monthly].gt(requirement.variable.to_i)
    end
    scope.where(where)
  end
end
