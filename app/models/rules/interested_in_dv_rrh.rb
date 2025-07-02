###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::InterestedInDvRrh < Rule
  def description
    'Matches clients who are interested in DV Rapid Re-Housing as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.dv_rrh_desired missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:dv_rrh_desired.to_s)

    scope.where(dv_rrh_desired: requirement.positive)
  end
end
