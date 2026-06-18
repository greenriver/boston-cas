###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::MajorityUnsheltered < Rule
  def description
    'Matches clients whose most recent current living situation is not sheltered. Only used in some installations'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.majority_sheltered missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:majority_sheltered.to_s)

    scope.where(majority_sheltered: ! requirement.positive)
  end
end
