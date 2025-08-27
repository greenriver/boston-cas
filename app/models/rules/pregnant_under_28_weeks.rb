###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::PregnantUnder28Weeks < Rule
  def description
    'Matches clients who are pregnant and under 28 weeks along. No longer in use.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.pregnant_under_28_weeks missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:pregnant_under_28_weeks.to_s)

    scope.where(pregnant_under_28_weeks: requirement.positive)
  end
end
