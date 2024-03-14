###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::HousingBarrier < Rule
  def clients_that_fit(scope, requirement, _opportunity)
    if Client.column_names.include?(:housing_barrier.to_s)
      scope.where(housing_barrier: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.housing_barrier missing. Cannot check clients against #{self.class}.")
    end
  end
end
