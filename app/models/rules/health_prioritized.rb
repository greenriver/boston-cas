###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::HealthPrioritized < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:health_prioritized.to_s)
      if requirement.positive
        scope.where(health_prioritized: true)
      else
        scope.where(health_prioritized: false)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.health_prioritized missing. Cannot check clients against #{self.class}.")
    end
  end
end
