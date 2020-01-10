###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::PhysicalDisablingCondition < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:physical_disability.to_s)
      scope.where(physical_disability: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.physical_disability missing. Cannot check clients against #{self.class}.")
    end
  end
end
