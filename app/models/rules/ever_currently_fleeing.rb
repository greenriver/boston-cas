###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::EverCurrentlyFleeing < Rule
  def description
    'Matches clients who have ever indicated they are currently fleeing, either based on HUD HMIS data or as indicated on an assessment, depending on warehouse configuration.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    column = :currently_fleeing

    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    scope.where(column => requirement.positive)
  end
end
