###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::EnrolledInPh < Rule
  def description
    'Matches clients who are enrolled in a PH project (project types 9 and 10) with a move-in date in the past.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.enrolled_in_ph missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:enrolled_in_ph.to_s)

    scope.where(enrolled_in_ph: requirement.positive)
  end
end
