###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::PregnantUnder28Weeks < Rule
  def clients_that_fit(scope, requirement, opportunity) # rubocop:disable Lint/UnusedMethodArgument
    raise RuleDatabaseStructureMissing.new("clients.pregnant_under_28_weeks missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:pregnant_under_28_weeks.to_s)

    scope.where(pregnant_under_28_weeks: requirement.positive)
  end
end
