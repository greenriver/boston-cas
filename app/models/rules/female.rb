###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::Female < Rule
  def description
    'Matches clients whose gender is female.'
  end

  def clients_that_fit(scope, requirement, opportunity) # rubocop:disable Lint/UnusedMethodArgument
    column = :female
    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    scope.where(column => requirement.positive)
  end
end
