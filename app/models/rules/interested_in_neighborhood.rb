###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::InterestedInNeighborhood < Rule
  def variable_requirement?
    true
  end

  def available_neighborhoods
    Neighborhood.order(:name).pluck(:id, :name)
  end

  def display_for_variable value
    available_neighborhoods.to_h.try(:[], value.to_i) || value
  end

  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:neighborhood_interests.to_s)
      if requirement.positive
        where = 'neighborhood_interests @> ? OR neighborhood_interests = \'[]\''
      else
        where = 'not(neighborhood_interests @> ?) OR neighborhood_interests = \'[]\''
      end
      scope.where(where, requirement.variable.to_s)
    else
      raise RuleDatabaseStructureMissing.new("clients.neighborhood_interests missing. Cannot check clients against #{self.class}.")
    end
  end
end
