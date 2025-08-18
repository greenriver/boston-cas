###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::InterestedInSetAsides < Rule
  def description
    'Matches clients who are interested in set-asides as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.interested_in_set_asides missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:interested_in_set_asides.to_s)

    scope.where(interested_in_set_asides: requirement.positive)
  end
end
