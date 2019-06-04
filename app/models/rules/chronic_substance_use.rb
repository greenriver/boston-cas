###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::ChronicSubstanceUse < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:substance_abuse_problem.to_s)
      scope.where(substance_abuse_problem: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.substance_abuse_problem missing. Cannot check clients against #{self.class}.")
    end
  end
end
