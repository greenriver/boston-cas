###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::AgeGreaterThanFiftyFive < Rule
  def description
    'Matches clients who are 55 years or older.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.date_of_birth missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:date_of_birth.to_s)

    years_ago = Date.current - 55.years
    if requirement.positive
      scope.where(c_t[:date_of_birth].lteq(years_ago))
    else
      scope.where(c_t[:date_of_birth].gt(years_ago))
    end
  end
end
