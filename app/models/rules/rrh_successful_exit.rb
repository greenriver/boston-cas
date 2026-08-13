###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::RrhSuccessfulExit < Rule
  def description
    "Matches clients who are #{Translation.translate('Able to successfully exit 12-24 month RRH program').downcase} as indicated on an assessment."
  end

  def clients_that_fit(scope, requirement, _opportunity)
    column = :rrh_successful_exit
    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    scope.where(column => requirement.positive)
  end
end
