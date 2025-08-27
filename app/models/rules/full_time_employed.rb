###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::FullTimeEmployed < Rule
  def description
    "Matches clients who have indicated they are #{Translation.translate('Employed full-time').downcase} on an assessment."
  end

  def clients_that_fit(scope, requirement, _opportunity)
    column = :full_time_employed
    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    scope.where(column => requirement.positive)
  end
end
