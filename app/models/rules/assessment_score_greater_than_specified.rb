###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::AssessmentScoreGreaterThanSpecified < Rule
  def variable_requirement?
    true
  end

  def available_scores
    @available_scores ||= Array.new(20) { |i| (i + 1) * 5 }.map{|i| [i, i] }
  end

  def display_for_variable(value)
    available_scores.to_h.try(:[], value.to_i) || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    if Client.column_names.include?(:enrolled_project_ids.to_s)
      if requirement.positive
        where = c_t[:assessment_score].gt(requirement.variable.to_i)
      else
        where = c_t[:assessment_score].lteq(requirement.variable.to_i)
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new('clients.assessment_score missing. Cannot check clients against #{self.class}.')
    end
  end
end
