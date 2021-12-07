###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::MajoritySheltered < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:majority_sheltered.to_s)
      scope.where(majority_sheltered: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.majority_sheltered missing. Cannot check clients against #{self.class}.")
    end
  end
end
