###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::AgeGreaterThanFortyFive < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:date_of_birth.to_s)
      years_ago = Date.today - 45.years
      if requirement.positive
        where = "date_of_birth <= ?"
      else
        where = "date_of_birth > ?"
      end
      scope.where(where, years_ago)
    else
      raise RuleDatabaseStructureMissing.new("clients.date_of_birth missing. Cannot check clients against #{self.class}.")
    end
  end
end
