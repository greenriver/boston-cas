###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::CanWorkFullTime < Rule
  def description
    'Matches clients who are able to work full time as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    column = :can_work_full_time
    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    scope.where(column => requirement.positive)
  end
end
