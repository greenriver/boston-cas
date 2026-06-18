###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::DisablingCondition < Rule
  def description
    'Matches clients who have at least one disabling condition in their most recent HUD disability response or have indicated they have a disabling condition at the enrollment level.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.disabling_condition missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:disabling_condition.to_s)

    scope.where(disabling_condition: requirement.positive)
  end
end
