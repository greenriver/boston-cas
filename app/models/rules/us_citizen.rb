###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::UsCitizen < Rule
  def description
    'Matches clients who are US citizens. No longer in use.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.us_citizen missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:us_citizen.to_s)

    scope.where(us_citizen: requirement.positive)
  end
end
