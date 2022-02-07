###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::IneligibleImmigrant < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:ineligible_immigrant.to_s)
      scope.where(ineligible_immigrant: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.ineligible_immigrant missing. Cannot check clients against #{self.class}.")
    end
  end
end
