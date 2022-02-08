###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::SeenInLastFortyFiveDays < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if last_seen = c_t[:calculated_last_homeless_night]
      if requirement.positive
        where = c_t[:calculated_last_homeless_night].gteq( 45.days.ago )
      else
        where = c_t[:calculated_last_homeless_night].lt( 45.days.ago )
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("calculated_last_homeless_night is missing. Cannot check clients against #{self.class}.")
    end
  end
end
