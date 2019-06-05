###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::InterestedInYouthRrh < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:youth_rrh_desired.to_s)
      scope.where(youth_rrh_desired: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.youth_rrh_desired missing. Cannot check clients against #{self.class}.")
    end
  end
end
