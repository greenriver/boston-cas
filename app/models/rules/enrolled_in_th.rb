###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::EnrolledInTh < Rule
  def description
    'Matches clients who are enrolled in a TH project (project type 2).'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.enrolled_in_th missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:enrolled_in_th.to_s)

    scope.where(enrolled_in_th: requirement.positive)
  end
end
