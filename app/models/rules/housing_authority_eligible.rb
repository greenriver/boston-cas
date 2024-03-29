###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::HousingAuthorityEligible < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:ha_eligible.to_s)
      scope.where(ha_eligible: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.ha_eligible missing. Cannot check clients against #{self.class}.")
    end
  end
end
