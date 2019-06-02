###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::HuesEligible < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:hues_eligible.to_s)
      scope.where(hues_eligible: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.hues_eligible missing. Cannot check clients against #{self.class}.")
    end
  end
end
