###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
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
