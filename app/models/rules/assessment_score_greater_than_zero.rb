###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::AssessmentScoreGreaterThanZero < Rule
  def description
    'Matches clients who have an assessment score greater than zero.  The goal of this rule is to match clients who have been assessed.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.assessment_score missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:assessment_score.to_s)

    if requirement.positive
      where = c_t[:assessment_score].gt(0)
    else
      where = c_t[:assessment_score].lteq(0)
    end
    scope.where(where)
  end
end
