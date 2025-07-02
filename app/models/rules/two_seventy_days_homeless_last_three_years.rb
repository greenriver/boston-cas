###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::TwoSeventyDaysHomelessLastThreeYears < Rule
  def description
    'Matches clients who have been homeless for at least 270 days in the last three years.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.days_homeless_in_last_three_years missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:days_homeless_in_last_three_years.to_s)

    if requirement.positive
      where = c_t[:days_homeless_in_last_three_years].gteq(270)
    else
      where = c_t[:days_homeless_in_last_three_years].lt(270)
    end
    scope.where(where)
  end
end
