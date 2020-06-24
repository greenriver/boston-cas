###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::NeverEvicted < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:evicted.to_s)
      scope.where.not(evicted: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.evicted missing. Cannot check clients against #{self.class}.")
    end
  end
end
