###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::Challenge < Rule
  def variable_requirement?
    true
  end

  def available_challenges
    [
      'No Income/Set Income',
      'Domestic Violence',
      'No rental history',
      'Bad Credit',
      'Eviction History',
      'Misdemeanor',
      'Felony Conviction /Criminal History',
      'Sex Offender',
      'Meth production conviction',
    ].map { |v| [v.downcase, v] }
  end

  def display_for_variable value
    available_strengths.to_h[value] || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    column = :challenges
    raise RuleDatabaseStructureMissing.new("clients.#{column} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s)

    connection = self.class.connection
    where = if requirement.positive
      Arel.sql("#{connection.quote_column_name(column)} @> '\"#{requirement.variable.downcase}\"'")
    else
      Arel.sql("not(#{connection.quote_column_name(column)} @> '\"#{requirement.variable.downcase}\"')")
    end
    scope.where(where).
      or(scope.where(Arel.sql("#{connection.quote_column_name(column)} = '[]'"))).
      or(scope.where(column => nil))
  end
end
