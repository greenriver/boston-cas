###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::Pregnant < Rule
  def description
    'Matches clients who are pregnant as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.pregnancy_status missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:pregnancy_status.to_s)

    scope.where(pregnancy_status: requirement.positive)
  end
end
