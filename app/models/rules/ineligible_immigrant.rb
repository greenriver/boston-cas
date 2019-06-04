###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::IneligibleImmigrant < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:ineligible_immigrant.to_s)
      scope.where(ineligible_immigrant: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.ineligible_immigrant missing. Cannot check clients against #{self.class}.")
    end
  end
end
