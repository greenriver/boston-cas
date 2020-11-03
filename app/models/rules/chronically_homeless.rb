###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::ChronicallyHomeless < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:chronic_homeless.to_s)
      scope.where(chronic_homeless: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.chronic_homeless missing. Cannot check clients against #{self.class}.")
    end
  end

  def always_apply?
    false
  end
end
