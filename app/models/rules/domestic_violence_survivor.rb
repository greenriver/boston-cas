###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::DomesticViolenceSurvivor < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:domestic_violence.to_s)
      scope.where(domestic_violence: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.domestic_violence missing. Cannot check clients against #{self.class}.")
    end
  end
end
