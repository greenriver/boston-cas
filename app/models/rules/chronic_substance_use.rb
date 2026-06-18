###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::ChronicSubstanceUse < Rule
  def description
    'Matches clients whose most recent HUD disability response indicates they have a substance use disorder.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.substance_abuse_problem missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:substance_abuse_problem.to_s)

    scope.where(substance_abuse_problem: requirement.positive)
  end
end
