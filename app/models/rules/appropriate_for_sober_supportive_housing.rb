###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::AppropriateForSoberSupportiveHousing < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:sober_housing.to_s)
      if requirement.positive
        scope.where(sober_housing: true)
      else
        scope.where(sober_housing: false)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.sober_housing missing. Cannot check clients against #{self.class}.")
    end
  end
end
