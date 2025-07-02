###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::Income < Rule
  def description
    'Matches clients who have an income as indicated on a HUD assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.income_total_monthly missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:income_total_monthly.to_s)

    if requirement.positive
      where = c_t[:income_total_monthly].gt(0)
    else
      where = c_t[:income_total_monthly].eq(0).or(c_t[:income_total_monthly].eq(nil))
    end
    scope.where(where)
  end
end
