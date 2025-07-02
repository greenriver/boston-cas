###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::WillingToWorkFullTime < Rule
  def description
    "Matches clients who are #{Translation.translate('Willing to work full-time').downcase}."
  end

  def clients_that_fit(scope, requirement, _opportunity)
    column = :willing_to_work_full_time
    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    scope.where(column => requirement.positive)
  end
end
