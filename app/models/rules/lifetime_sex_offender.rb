###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::LifetimeSexOffender < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:lifetime_sex_offender.to_s)
      scope.where(lifetime_sex_offender: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.lifetime_sex_offender missing. Cannot check clients against #{self.class}.")
    end
  end
end
