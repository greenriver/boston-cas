###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::HuesEligible < Rule
  def description
    'Matches clients who are HUES eligible. This is no longer in use.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.hues_eligible missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:hues_eligible.to_s)

    scope.where(hues_eligible: requirement.positive)
  end
end
