###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::EnrolledInHmisProjectTypeAnyPhNoMoveIn < Rule
  def variable_requirement?
    true
  end

  def available_project_types
    {
      ph: 'PH - Permanent Housing - without move-in',
      psh: 'PSH - Permanent Supportive Housing - without move-in',
      rrh: 'RRH - Rapid Re-Housing - without move-in',
    }
  end

  def display_for_variable value
    # Note, we need to jump through a few hoops since variable wasn't designed as a json field
    available_project_types.select { |id, _| id.to_s.in?(value_as_array(value)) }.map(&:last).join(' or ') || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    type_columns = {
      ph: 'enrolled_in_ph_pre_move_in',
      psh: 'enrolled_in_psh_pre_move_in',
      rrh: 'enrolled_in_rrh_pre_move_in',
    }
    raise RuleDatabaseStructureMissing.new("Missing one or more project type columns. Cannot check clients against #{self.class}.") unless type_columns.values.all? { |name| Client.column_names.include?(name) }

    a_t = Client.arel_table
    clauses = value_as_array(requirement.variable).map do |project_type|
      next if type_columns[project_type.to_sym].blank?

      a_t[type_columns[project_type.to_sym]].eq(requirement.positive).to_sql
    end.compact

    type_clauses = if requirement.positive
      clauses.join(' or ')
    else
      clauses.join(' and ')
    end

    scope.where(Arel.sql(type_clauses))
  end

  private def value_as_array(value)
    value.split(',')
  end
end
