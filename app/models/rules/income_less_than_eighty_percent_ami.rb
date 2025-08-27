###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::IncomeLessThanEightyPercentAmi < Rule
  def description
    'Matches clients who have an income less than 80% of the AMI. NOTE: AMI is set on the site configuration page.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.income_total_monthly missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:income_total_monthly.to_s)

    ami = Config.get(:ami)
    ami_partial = (ami * 0.8) / 12 # 80% AMI
    if requirement.positive
      where = c_t[:income_total_monthly].lteq(ami_partial).
        or(c_t[:income_total_monthly].eq(nil))
    else
      where = c_t[:income_total_monthly].gt(ami_partial)
    end
    scope.where(where)
  end
end
