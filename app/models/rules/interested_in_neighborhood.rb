###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::InterestedInNeighborhood < Rule
  def description
    'Matches clients who are interested in a specific neighborhood as indicated on an assessment.  This rule also matches any client who has not indicated a neighborhood preference.'
  end

  def variable_requirement?
    true
  end

  def available_neighborhoods
    Neighborhood.order(:name).pluck(:id, :name)
  end

  def display_for_variable value
    available_neighborhoods.to_h.try(:[], value.to_i) || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.neighborhood_interests missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:neighborhood_interests.to_s)

    if requirement.positive
      where = 'neighborhood_interests @> ? OR neighborhood_interests = \'[]\''
    else
      where = 'not(neighborhood_interests @> ?) OR neighborhood_interests = \'[]\''
    end
    scope.where(where, requirement.variable.to_s)
  end
end
