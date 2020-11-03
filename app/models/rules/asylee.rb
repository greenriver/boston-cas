###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::Asylee < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:asylee.to_s)
      scope.where(asylee: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.asylee missing. Cannot check clients against #{self.class}.")
    end
  end
end
