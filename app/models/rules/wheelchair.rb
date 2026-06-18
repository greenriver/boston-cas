###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::Wheelchair < Rule
  def description
    'Matches clients who require wheelchair accessibility as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.requires_wheelchair_accessibility missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:requires_wheelchair_accessibility.to_s)

    scope.where(requires_wheelchair_accessibility: requirement.positive)
  end
end
