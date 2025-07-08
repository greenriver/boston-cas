###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::VerifiedDaysHomeless < Rule
  def description
    'Matches clients who have had their days homeless verified. This rule is not currently receiving new data.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.date_days_homeless_verified missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:date_days_homeless_verified.to_s)

    if requirement.positive
      scope.where.not(date_days_homeless_verified: nil)
    else
      scope.where(date_days_homeless_verified: nil)
    end
  end
end
