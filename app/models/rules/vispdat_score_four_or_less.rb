###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::VispdatScoreFourOrLess < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:vispdat_score.to_s)
      if requirement.positive
        where = c_t[:vispdat_score].lteq(4)
      else
        where = c_t[:vispdat_score].gt(4)
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.vispdat_score missing. Cannot check clients against #{self.class}.")
    end
  end
end
