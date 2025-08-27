###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::DomesticViolenceSurvivor < Rule
  def description
    'Matches clients who have indicated they are a domestic violence survivor on an assessment or via a HUD assessment within the chosen time period as defined in the warehouse configuration. Non-HMIS clients are marked as survivors if they have indicated they are currently fleeing, interested in DV RRH, or deidentified.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.domestic_violence missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:domestic_violence.to_s)

    value = if requirement.positive then 1 else 0 end
    scope.where(domestic_violence: value)
  end
end
