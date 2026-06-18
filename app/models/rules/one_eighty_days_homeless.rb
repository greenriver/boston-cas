###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::OneEightyDaysHomeless < Rule
  def description
    'Matches clients who have been homeless for 180 days or more (all-time).'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.days_homeless missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:days_homeless.to_s)

    if requirement.positive
      where = c_t[:days_homeless].gteq(180)
    else
      where = c_t[:days_homeless].lt(180)
    end
    scope.where(where)
  end
end
