###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::IneligibleImmigrant < Rule
  def description
    'Matches clients who are ineligible for immigration status. This is no longer in use.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.ineligible_immigrant missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:ineligible_immigrant.to_s)

    scope.where(ineligible_immigrant: requirement.positive)
  end
end
