###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::AgeGreaterThanTwentyOne < Rule
  def description
    'Matches clients who are 21 years or older.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    if Client.column_names.include?(:date_of_birth.to_s) # rubocop:disable Style/GuardClause
      years_ago = Date.current - 21.years
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
