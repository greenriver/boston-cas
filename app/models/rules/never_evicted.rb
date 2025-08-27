###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::NeverEvicted < Rule
  def description
    'Matches clients who have not indicated they have been evicted as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.evicted missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:evicted.to_s)

    scope.where.not(evicted: requirement.positive)
  end
end
