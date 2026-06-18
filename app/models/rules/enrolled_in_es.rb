###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::EnrolledInEs < Rule
  def description
    'Matches clients who are enrolled in emergency shelter.  Non-HMIS clients may be able to indicate enrollment in ES on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.enrolled_in_es missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:enrolled_in_es.to_s)

    scope.where(enrolled_in_es: requirement.positive)
  end
end
