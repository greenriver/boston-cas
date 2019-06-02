###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::AssessmentScoreGreaterThanZero < Rule
  def clients_that_fit(scope, requirement)
    c_t = Client.arel_table
    if Client.column_names.include?(:assessment_score.to_s)
      if requirement.positive
        where = c_t[:assessment_score].gt(0)
      else
        where = c_t[:assessment_score].lteq(0)
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.assessment_score missing. Cannot check clients against #{self.class}.")
    end
  end
end
