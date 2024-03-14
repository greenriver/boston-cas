###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::Strength < Rule
  def variable_requirement?
    true
  end

  def available_strengths
    [
      'Employable Skills',
      'Employment Income',
      'Good Credit',
      'No Disabling Conditions',
      'Recent Positive Rental History',
      'Reliable Vehicle',
      'Regular Income',
    ].map { |v| [v.downcase, v] }
  end

  def display_for_variable value
    available_strengths.to_h[value] || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    column = :strengths
    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    if requirement.positive
      # Any match? (must have at least one)
      where = 'strengths ?| ARRAY [:variable]'
    else
      # none match (can't have any)
      where = 'not(strengths ?| ARRAY [:variable]) OR strengths is null'
    end
    scope.where(where, variable: value_as_array(requirement.variable))
  end

  private def value_as_array(value)
    value.split(',')
  end
end
