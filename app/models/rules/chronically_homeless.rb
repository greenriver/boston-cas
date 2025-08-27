###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::ChronicallyHomeless < Rule
  def description
    'Matches clients who are chronically homeless as defined in the warehouse configuration.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.chronic_homeless missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:chronic_homeless.to_s)

    scope.where(chronic_homeless: requirement.positive)
  end

  def always_apply?
    false
  end
end
