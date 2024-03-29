###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::MiSaOrCoMorbid < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:mental_health_problem.to_s) && Client.column_names.include?(:substance_abuse_problem.to_s)
      if requirement.positive
        scope.where(c_t[:mental_health_problem].eq(true).or(c_t[:substance_abuse_problem].eq(true)))
      else
        scope.where(mental_health_problem: false, substance_abuse_problem: false)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.mental_health_problem or clients.substance_abuse_problem missing. Cannot check clients against #{self.class}.")
    end
  end
end
