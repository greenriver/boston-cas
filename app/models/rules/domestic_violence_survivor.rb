###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::DomesticViolenceSurvivor < Rule
  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.domestic_violence missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:domestic_violence.to_s)

    value = if requirement.positive then 1 else 0 end
    scope.where(domestic_violence: value)
  end
end
