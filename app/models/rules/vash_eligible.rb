###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
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
