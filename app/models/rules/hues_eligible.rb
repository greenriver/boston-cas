###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::HuesEligible < Rule
  def description
    'Matches clients who are HUES eligible. This is no longer in use.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.hues_eligible missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:hues_eligible.to_s)

    scope.where(hues_eligible: requirement.positive)
  end
end
