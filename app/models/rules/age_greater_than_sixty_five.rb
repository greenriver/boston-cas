###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::AgeGreaterThanSixtyFive < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:date_of_birth.to_s)
      years_ago = Date.current - 65.years
      if requirement.positive
        scope.where(c_t[:date_of_birth].lteq(years_ago).or(c_t[:older_than_65].eq(true)))
      else
        scope.where(c_t[:date_of_birth].gt(years_ago))
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.date_of_birth missing. Cannot check clients against #{self.class}.")
    end
  end
end
