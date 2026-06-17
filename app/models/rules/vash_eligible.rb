###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::VashEligible < Rule
  def description
    'Matches clients who are VASH eligible. No longer in use.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.vash_eligible missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:vash_eligible.to_s)

    scope.where(vash_eligible: requirement.positive)
  end
end
