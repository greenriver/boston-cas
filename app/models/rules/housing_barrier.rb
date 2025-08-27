###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::HousingBarrier < Rule
  def description
    "Matches clients who have a #{Translation.translate('Housing Barrier').downcase} as indicated in an assessment. "
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.housing_barrier missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:housing_barrier.to_s)

    scope.where(housing_barrier: requirement.positive)
  end
end
