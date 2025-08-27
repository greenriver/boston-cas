###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::HousingForFormerlyHomeless < Rule
  def description
    'Matches clients who prefer to live in a community with others who are formerly homeless as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    column = :housing_for_formerly_homeless
    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    scope.where(column => requirement.positive)
  end
end
