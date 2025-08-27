###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::TwoSeventyDaysHomeless < Rule
  def description
    'Matches clients who have been homeless for at least 270 days (all-time).'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.days_homeless missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:days_homeless.to_s)

    if requirement.positive
      where = c_t[:days_homeless].gteq(270)
    else
      where = c_t[:days_homeless].lt(270)
    end
    scope.where(where)
  end
end
