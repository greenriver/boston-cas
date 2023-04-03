###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::AssessmentCompletedWithin < Rule
  def variable_requirement?
    true
  end

  def available_options
    @available_options ||= [
      [30, 'Last Month'],
      [90, 'Last Three Months'],
      [180, 'Last Six Months'],
      [365, 'Last Year'],
      [730, 'Last Two Years'],
    ]
  end

  def display_for_variable(value)
    available_options.to_h.try(:[], value.to_i) || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.rrh_assessment_collected_at missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:rrh_assessment_collected_at.to_s)

    date = Date.current - requirement.variable.to_i.days
    if requirement.positive
      where = c_t[:rrh_assessment_collected_at].gt(date)
    else
      where = c_t[:rrh_assessment_collected_at].lteq(date)
    end
    scope.where(where)
  end
end
