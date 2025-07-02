###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::Wheelchair < Rule
  def description
    'Matches clients who require wheelchair accessibility.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.requires_wheelchair_accessibility missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:requires_wheelchair_accessibility.to_s)

    scope.where(requires_wheelchair_accessibility: requirement.positive)
  end
end
