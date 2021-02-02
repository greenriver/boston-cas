###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::OneEightyDaysHomelessLastThreeYears < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:days_homeless_in_last_three_years.to_s)
      if requirement.positive
        where = c_t[:days_homeless_in_last_three_years].gteq(180)
      else
        where = c_t[:days_homeless_in_last_three_years].lt(180)
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.days_homeless_in_last_three_years missing. Cannot check clients against #{self.class}.")
    end
  end
end
