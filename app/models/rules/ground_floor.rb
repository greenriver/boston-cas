###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::GroundFloor < Rule
  def description
    'Matches clients who require elevator access or a ground floor unit.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.requires_elevator_access missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:requires_elevator_access.to_s)

    scope.where(requires_elevator_access: requirement.positive)
  end
end
