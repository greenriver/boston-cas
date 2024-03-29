###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::SsvfEligible < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:ssvf_eligible.to_s)
      scope.where(ssvf_eligible: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.ssvf_eligible missing. Cannot check clients against #{self.class}.")
    end
  end
end
