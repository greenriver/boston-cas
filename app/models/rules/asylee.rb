###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::Asylee < Rule
  def description
    'Matches clients who are are seeking asylum. This rule is not currently receiving new data.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.asylee missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:asylee.to_s)

    scope.where(asylee: requirement.positive)
  end
end
