###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::NonHmisAssessmentType < Rule
  def variable_requirement?
    true
  end

  def available_assessments
    @available_assessments ||= NonHmisAssessment.known_assessments_for_matching
  end

  def display_for_variable value
    # Note, we need to jump through a few hoops since variable wasn't designed as a json field
    available_assessments.select { |id, _| id.to_s.in?(value_as_array(value)) }.map(&:last).join(' or ') || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    if Client.column_names.include?(:assessment_name.to_s)
      where = "'#{value_as_array(requirement.variable)}'::jsonb ? assessment_name"
      where = "not(#{where}) OR assessment_name is null" unless requirement.positive
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.assessment_name missing. Cannot check clients against #{self.class}.")
    end
  end

  private def value_as_array(value)
    value.split(',')
  end
end
