###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::EnrolledInPsh < Rule
  def description
    'Matches clients who are enrolled in a PSH project (project type 3) with a move-in date in the past.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.enrolled_in_psh missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:enrolled_in_psh.to_s)

    scope.where(enrolled_in_psh: requirement.positive)
  end
end
