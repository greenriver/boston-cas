###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::AppropriateForSoberSupportiveHousing < Rule
  def description
    'Matches clients who are appropriate for sober supportive housing as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.sober_housing missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:sober_housing.to_s)

    if requirement.positive
      scope.where(sober_housing: true)
    else
      scope.where(sober_housing: false)
    end
  end
end
