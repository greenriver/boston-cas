###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::SsvfEligible < Rule
  def description
    'Matches clients who are SSVF eligible as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.ssvf_eligible missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:ssvf_eligible.to_s)

    scope.where(ssvf_eligible: requirement.positive)
  end
end
