###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::EnrolledInTh < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:enrolled_in_th.to_s)
      scope.where(enrolled_in_th: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.enrolled_in_th missing. Cannot check clients against #{self.class}.")
    end
  end
end
