###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::MentalHealthEligible < Rule
  def description
    'Matches clients whose most recent HUD disability response indicates they have a mental health disability.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.mental_health_problem missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:mental_health_problem.to_s)

    scope.where(mental_health_problem: requirement.positive)
  end
end
