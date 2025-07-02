###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::ServiceNeed < Rule
  def description
    "Matches clients who have indicated they have a #{Translation.translate('Service Need').downcase} as indicated on an assessment."
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.service_need missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:service_need.to_s)

    scope.where(service_need: requirement.positive)
  end
end
