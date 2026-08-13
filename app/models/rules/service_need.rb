###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
