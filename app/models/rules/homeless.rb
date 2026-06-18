###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::Homeless < Rule
  def description
    'Matches clients who are available.  This rule is always applied.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.available missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:available.to_s)

    scope.where(available: requirement.positive)
  end

  def always_apply?
    true
  end
end
