###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::Veteran < Rule
  def description
    'Matches clients whose HMIS Veteran Status is Yes.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.veteran missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:veteran.to_s)

    scope.where(veteran: requirement.positive)
  end
end
