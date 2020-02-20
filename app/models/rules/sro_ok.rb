###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::SroOk < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:sro_ok.to_s)
      scope.where(sro_ok: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.sro_ok missing. Cannot check clients against #{self.class}.")
    end
  end
end
