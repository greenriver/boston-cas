###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::GroundFloor < Rule
  def description
    'Matches clients who require elevator access or a ground floor unit.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.requires_elevator_access missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:requires_elevator_access.to_s)

    scope.where(requires_elevator_access: requirement.positive)
  end
end
