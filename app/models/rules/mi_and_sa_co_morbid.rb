###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::MiAndSaCoMorbid < Rule
  def description
    'Matches clients who have both a mental health disorder and a substance use disorder as seen in the most recent HUD disability response.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.mental_health_problem or clients.substance_abuse_problem missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:mental_health_problem.to_s) && Client.column_names.include?(:substance_abuse_problem.to_s)

    if requirement.positive
      scope.where(mental_health_problem: true, substance_abuse_problem: true)
    else
      scope.where(c_t[:mental_health_problem].eq(false).or(c_t[:substance_abuse_problem].eq(false)))
    end
  end
end
