###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::ChildInHousehold < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:child_in_household.to_s)
      scope.where(child_in_household: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.child_in_household missing. Cannot check clients against #{self.class}.")
    end
  end
end
