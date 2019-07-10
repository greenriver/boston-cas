###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::VispdatScoreFourOrLess < Rule
  def clients_that_fit(scope, requirement)
    c_t = Client.arel_table
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
