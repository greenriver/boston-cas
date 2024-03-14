###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::RequireInterestInNeighborhood < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:neighborhood_interests.to_s)
      if requirement.positive
        where = 'not(neighborhood_interests = \'[]\')'
      else
        where = 'neighborhood_interests = \'[]\''
      end
      scope.where(where, requirement.variable.to_s)
    else
      raise RuleDatabaseStructureMissing.new("clients.neighborhood_interests missing. Cannot check clients against #{self.class}.")
    end
  end
end
