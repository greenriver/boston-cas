###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::ChildInHousehold < Rule
  def description
    "Matches clients who have indicated there are #{Translation.translate('Children under age 18 in household').downcase} as indicated on an assessment."
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.child_in_household missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:child_in_household.to_s)

    scope.where(child_in_household: requirement.positive)
  end
end
