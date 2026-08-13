###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::VispdatScoreEightOrMore < Rule
  def description
    'Matches clients who have a VISPDAT score of 8 or more as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.vispdat_score missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:vispdat_score.to_s)

    if requirement.positive
      where = c_t[:vispdat_score].gteq(8)
    else
      where = c_t[:vispdat_score].lt(8)
    end
    scope.where(where)
  end
end
