###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::EmployedThreeMonths < Rule
  def description
    "Matches clients who have been #{Translation.translate('Employed for 3 or more months').downcase} as indicated on an assessment, not HUD related."
  end

  def clients_that_fit(scope, requirement, _opportunity)
    column = :employed_three_months
    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    scope.where(column => requirement.positive)
  end
end
