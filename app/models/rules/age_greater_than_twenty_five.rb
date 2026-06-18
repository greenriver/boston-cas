###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::AgeGreaterThanTwentyFive < Rule
  def description
    'Matches clients who are 25 years or older.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.date_of_birth missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:date_of_birth.to_s)

    years_ago = Date.current - 25.years
    if requirement.positive
      scope.where(c_t[:date_of_birth].lteq(years_ago))
    else
      scope.where(c_t[:date_of_birth].gt(years_ago))
    end
  end
end
