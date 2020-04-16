###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::AgeGreaterThanTwentyFive < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:date_of_birth.to_s)
      years_ago = Date.current - 25.years
      if requirement.positive
        scope.where(c_t[:date_of_birth].lteq(years_ago))
      else
        scope.where(c_t[:date_of_birth].gt(years_ago))
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.date_of_birth missing. Cannot check clients against #{self.class}.")
    end
  end
end
