###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::EncampmentDecommissioned < Rule
  def description
    'Matches clients who have been in a decommissioned encampment as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    column = :encampment_decomissioned
    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    scope.where(column => requirement.positive)
  end
end
