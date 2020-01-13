###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::CspechEligible < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:cspech_eligible.to_s)
      scope.where(cspech_eligible: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.cspech_eligible missing. Cannot check clients against #{self.class}.")
    end
  end
end
