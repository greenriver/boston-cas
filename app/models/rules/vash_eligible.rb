###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::VashEligible < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:vash_eligible.to_s)
      scope.where(vash_eligible: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.vash_eligible missing. Cannot check clients against #{self.class}.")
    end
  end
end
