###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::MentalHealthEligible < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:mental_health_problem.to_s)
      scope.where(mental_health_problem: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.mental_health_problem missing. Cannot check clients against #{self.class}.")
    end
  end
end
