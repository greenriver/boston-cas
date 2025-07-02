###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::PhysicalDisablingCondition < Rule
  def description
    'Matches clients whose most recent HUD disability response indicates they have a physical disability.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.physical_disability missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:physical_disability.to_s)

    scope.where(physical_disability: requirement.positive)
  end
end
