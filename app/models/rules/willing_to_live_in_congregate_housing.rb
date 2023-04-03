###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::WillingToLiveInCongregateHousing < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:congregate_housing.to_s)
      if requirement.positive
        scope.where(congregate_housing: true)
      else
        scope.where(congregate_housing: false)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.congregate_housing missing. Cannot check clients against #{self.class}.")
    end
  end
end
