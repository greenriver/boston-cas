###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::Pregnant < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:pregnancy_status.to_s)
      scope.where(pregnancy_status: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.pregnancy_status missing. Cannot check clients against #{self.class}.")
    end
  end
end
