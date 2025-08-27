###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::LifetimeSexOffender < Rule
  def description
    'Matches clients who have been marked as lifetime sex offenders as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    column = :lifetime_sex_offender
    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    scope.where(column => requirement.positive)
  end
end
