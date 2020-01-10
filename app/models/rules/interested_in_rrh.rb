###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::InterestedInRrh < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:rrh_desired.to_s)
      scope.where(rrh_desired: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.rrh_desired missing. Cannot check clients against #{self.class}.")
    end
  end
end
