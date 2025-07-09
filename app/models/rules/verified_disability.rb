###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::VerifiedDisability < Rule
  def description
    'Matches clients who have had their disability verified in the warehouse..'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.disability_verified_on missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:disability_verified_on.to_s)

    if requirement.positive
      scope.where.not(disability_verified_on: nil)
    else
      scope.where(disability_verified_on: nil)
    end
  end
end
