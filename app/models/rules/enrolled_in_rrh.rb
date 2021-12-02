###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::EnrolledInRrh < Rule
  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.enrolled_in_rrh missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:enrolled_in_rrh.to_s)

    scope.where(enrolled_in_rrh: requirement.positive)
  end
end
