###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::DevelopmentalDisability < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:developmental_disability.to_s)
      scope.where(developmental_disability: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.developmental_disability missing. Cannot check clients against #{self.class}.")
    end
  end
end
