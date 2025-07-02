###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::EnrolledInRrh < Rule
  def description
    'Matches clients who are enrolled in a RRH project (project type 13) with a move-in date in the past.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.enrolled_in_rrh missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:enrolled_in_rrh.to_s)

    scope.where(enrolled_in_rrh: requirement.positive)
  end
end
