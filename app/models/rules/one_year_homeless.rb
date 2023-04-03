###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::OneYearHomeless < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:days_homeless.to_s)
      if requirement.positive
        where = c_t[:days_homeless].gteq(365)
      else
        where = c_t[:days_homeless].lt(365)
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.days_homeless missing. Cannot check clients against #{self.class}.")
    end
  end
end
