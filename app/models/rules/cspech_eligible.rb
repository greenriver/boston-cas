###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::CspechEligible < Rule
  def description
    "Matches clients who are #{Translation.translate('CSPECH Eligible')}. This rule is not currently receiving new data."
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.cspech_eligible missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:cspech_eligible.to_s)

    scope.where(cspech_eligible: requirement.positive)
  end
end
