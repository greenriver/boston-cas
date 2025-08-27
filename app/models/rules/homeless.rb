###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

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
