###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::DevelopmentalDisability < Rule
  def description
    'Matches clients whose most recent HUD disability response indicates they have a developmental disability.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.developmental_disability missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:developmental_disability.to_s)

    scope.where(developmental_disability: requirement.positive)
  end
end
