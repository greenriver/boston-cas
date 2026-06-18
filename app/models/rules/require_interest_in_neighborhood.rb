###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::RequireInterestInNeighborhood < Rule
  def description
    'Matches clients who have indicated they are interested in living in a specific neighborhood as indicated on an assessment.  Clients with no preferences are excluded.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.neighborhood_interests missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:neighborhood_interests.to_s)

    if requirement.positive
      where = 'not(neighborhood_interests = \'[]\')'
    else
      where = 'neighborhood_interests = \'[]\''
    end
    scope.where(where, requirement.variable.to_s)
  end
end
