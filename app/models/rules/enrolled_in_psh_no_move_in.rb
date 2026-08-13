###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::EnrolledInPshNoMoveIn < Rule
  def description
    'Matches clients who are enrolled in a PSH project (project type 3) without a move-in date.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    field = :enrolled_in_psh_pre_move_in
    raise RuleDatabaseStructureMissing.new("clients.#{field} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(field.to_s)

    scope.where(field => requirement.positive)
  end
end
