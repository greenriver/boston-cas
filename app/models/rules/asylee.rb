###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::Asylee < Rule
  def description
    'Matches clients who are are seeking asylum. This rule is not currently receiving new data.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.asylee missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:asylee.to_s)

    scope.where(asylee: requirement.positive)
  end
end
