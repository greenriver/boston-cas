###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::VaEligible < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:va_eligible.to_s)
      scope.where(va_eligible: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.va_eligible missing. Cannot check clients against #{self.class}.")
    end
  end
end
