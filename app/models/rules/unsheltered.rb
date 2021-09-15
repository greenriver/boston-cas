###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::Unsheltered < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:unsheltered.to_s)
      scope.where(unsheltered: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.unsheltered missing. Cannot check clients against #{self.class}.")
    end
  end

  def always_apply?
    true
  end
end
