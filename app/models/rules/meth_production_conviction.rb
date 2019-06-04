###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::MethProductionConviction < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:meth_production_conviction.to_s)
      scope.where(meth_production_conviction: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.meth_production_conviction missing. Cannot check clients against #{self.class}.")
    end
  end
end
