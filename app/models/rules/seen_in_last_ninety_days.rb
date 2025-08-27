###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::SeenInLastNinetyDays < Rule
  def description
    'Matches clients who have been seen in a homeless project in the last 90 days.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    last_seen = c_t[:calculated_last_homeless_night]
    raise RuleDatabaseStructureMissing.new("calculated_last_homeless_night is missing. Cannot check clients against #{self.class}.") unless last_seen.present?

    if requirement.positive
      where = c_t[:calculated_last_homeless_night].gteq(90.days.ago)
    else
      where = c_t[:calculated_last_homeless_night].lt(90.days.ago)
    end
    scope.where(where)
  end
end
