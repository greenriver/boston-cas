###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::OpenCase < Rule
  def description
    "Matches clients who have a #{Translation.translate('Current open case').downcase} as indicated on an assessment."
  end

  def clients_that_fit(scope, requirement, _opportunity)
    column = :open_case
    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    scope.where(column => requirement.positive)
  end
end
