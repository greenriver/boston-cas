###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::VaEligible < Rule
  def description
    'Matches clients who are VA eligible. No longer in use.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.va_eligible missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:va_eligible.to_s)

    scope.where(va_eligible: requirement.positive)
  end
end
