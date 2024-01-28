###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::EnrolledInSo < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:enrolled_in_so.to_s)
      scope.where(enrolled_in_so: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.enrolled_in_so missing. Cannot check clients against #{self.class}.")
    end
  end
end
