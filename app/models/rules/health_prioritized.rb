###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::HealthPrioritized < Rule
  def description
    'Matches clients who have been prioritized for health reasons. This is no longer in use.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.health_prioritized missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:health_prioritized.to_s)

    if requirement.positive
      scope.where(health_prioritized: true)
    else
      scope.where(health_prioritized: false)
    end
  end
end
