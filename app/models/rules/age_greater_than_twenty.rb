###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::AgeGreaterThanTwenty < Rule
  def clients_that_fit(scope, requirement, opportunity) # rubocop:disable Lint/UnusedMethodArgument
    if Client.column_names.include?(:date_of_birth.to_s) # rubocop:disable Style/GuardClause
      years_ago = Date.current - 20.years
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
