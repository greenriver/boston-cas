###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::Income < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:income_total_monthly.to_s)
      if requirement.positive
        where = c_t[:income_total_monthly].gt(0)
      else
        where = c_t[:income_total_monthly].eq(0).or(c_t[:income_total_monthly].eq(nil))
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.income_total_monthly missing. Cannot check clients against #{self.class}.")
    end
  end
end
