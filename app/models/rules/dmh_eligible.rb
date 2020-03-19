###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::DmhEligible < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:dmh_eligible.to_s)
      scope.where(dmh_eligible: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.dmh_eligible missing. Cannot check clients against #{self.class}.")
    end
  end
end
