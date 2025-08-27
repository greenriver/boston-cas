###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::EnrolledInSh < Rule
  def description
    'Matches clients who are enrolled in a SH project (project type 8).'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.enrolled_in_sh missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:enrolled_in_sh.to_s)

    scope.where(enrolled_in_sh: requirement.positive)
  end
end
