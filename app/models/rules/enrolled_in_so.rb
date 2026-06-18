###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::EnrolledInSo < Rule
  def description
    'Matches clients who are enrolled in a SO project (project type 4).'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.enrolled_in_so missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:enrolled_in_so.to_s)

    scope.where(enrolled_in_so: requirement.positive)
  end
end
