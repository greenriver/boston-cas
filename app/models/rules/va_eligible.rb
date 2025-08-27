###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::VaEligible < Rule
  def description
    'Matches clients who are VA eligible. No longer in use.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.va_eligible missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:va_eligible.to_s)

    scope.where(va_eligible: requirement.positive)
  end
end
