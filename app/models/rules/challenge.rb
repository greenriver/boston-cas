###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::Challenge < Rule
  def variable_requirement?
    true
  end

  def available_challenges
    [
      'Bad Credit',
      'Domestic Violence',
      'Eviction History',
      'Felony Conviction /Criminal History',
      'Meth production conviction',
      'Misdemeanor',
      'No Income/Set Income',
      'No rental history',
      'Sex Offender',
    ].map { |v| [v.downcase, v] }
  end

  def display_for_variable value
    available_challenges.to_h[value] || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    column = :challenges
    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    if requirement.positive
      # Any match? (must have at least one)
      where = 'challenges ?| ARRAY [:variable]'
    else
      # none match (can't have any)
      where = 'not(challenges ?| ARRAY [:variable]) OR challenges is null'
    end
    scope.where(where, variable: value_as_array(requirement.variable))
  end

  private def value_as_array(value)
    value.split(',')
  end
end
