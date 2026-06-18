###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::InterestedInRrh < Rule
  def description
    'Matches clients who are interested in Rapid Re-Housing as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.rrh_desired missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:rrh_desired.to_s)

    scope.where(rrh_desired: requirement.positive)
  end
end
