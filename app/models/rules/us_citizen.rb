###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::UsCitizen < Rule
  def description
    'Matches clients who are US citizens. No longer in use.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.us_citizen missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:us_citizen.to_s)

    scope.where(us_citizen: requirement.positive)
  end
end
