###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::AgeGreaterThanSixtyFive < Rule
  def description
    'Matches clients who are 65 years or older.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.date_of_birth missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:date_of_birth.to_s)

    years_ago = Date.current - 65.years
    if requirement.positive
      scope.where(c_t[:date_of_birth].lteq(years_ago).or(c_t[:older_than_65].eq(true)))
    else
      scope.where(c_t[:date_of_birth].gt(years_ago))
    end
  end
end
