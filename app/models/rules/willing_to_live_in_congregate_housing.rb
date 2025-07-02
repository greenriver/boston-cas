###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::WillingToLiveInCongregateHousing < Rule
  def description
    'Matches clients who are willing to live in congregate housing.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.congregate_housing missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:congregate_housing.to_s)

    if requirement.positive
      scope.where(congregate_housing: true)
    else
      scope.where(congregate_housing: false)
    end
  end
end
