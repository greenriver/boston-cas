###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::VispdatScoreEightOrMore < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:vispdat_score.to_s)
      if requirement.positive
        where = c_t[:vispdat_score].gteq(8)
      else
        where = c_t[:vispdat_score].lt(8)
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.vispdat_score missing. Cannot check clients against #{self.class}.")
    end
  end
end
