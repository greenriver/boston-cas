###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::VispdatScoreFourOrLess < Rule
  def description
    'Matches clients who have a VISPDAT score of 4 or less as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.vispdat_score missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:vispdat_score.to_s)

    if requirement.positive
      where = c_t[:vispdat_score].lteq(4)
    else
      where = c_t[:vispdat_score].gt(4)
    end
    scope.where(where)
  end
end
