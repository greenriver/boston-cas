###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::InterestedInDvRrh < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:dv_rrh_desired.to_s)
      scope.where(dv_rrh_desired: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.dv_rrh_desired missing. Cannot check clients against #{self.class}.")
    end
  end
end
