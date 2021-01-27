###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::IncomeLessThanFiftyPercentAmi < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:income_total_monthly.to_s)
      ami = Config.get(:ami)
      ami_partial = (ami * 0.5) / 12 #50% AMI
      if requirement.positive
        where = c_t[:income_total_monthly].lteq(ami_partial).
          or(c_t[:income_total_monthly].eq(nil))
      else
        where = c_t[:income_total_monthly].gt(ami_partial)
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.income_total_monthly missing. Cannot check clients against #{self.class}.")
    end
  end
end
