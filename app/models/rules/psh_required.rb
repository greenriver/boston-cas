###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::PshRequired < Rule
  def description
    'Matches clients who have indicated they are in need of PSH as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    column = :psh_required
    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    if requirement.positive
      scope.where(column => ['yes', 'maybe'])
    else
      scope.where(column => ['no', 'maybe'])
    end
  end
end
