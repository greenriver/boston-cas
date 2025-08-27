###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::DmhEligible < Rule
  def description
    'Matches clients who are eligible for the DMH program as defined in the warehouse configuration. This rule is not currently receiving new data.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.dmh_eligible missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:dmh_eligible.to_s)

    scope.where(dmh_eligible: requirement.positive)
  end
end
