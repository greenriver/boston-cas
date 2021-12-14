###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::EnrolledInHmisProjectType < Rule
  def variable_requirement?
    true
  end

  def available_project_types
    {
      es: "ES - Emergency Shelter",
      ph: "PH - Permanent Housing",
      psh: "PSH - Permanent Supportive Housing",
      rrh: 'RRH - Rapid Re-Housing',
      sh: 'SH - Safe Haven',
      so: 'SO - Street Outreach',
      th: 'Transitional Housing',
    }

  end

  def display_for_variable value
    # Note, we need to jump through a few hoops since variable wasn't designed as a json field
    available_project_types.select { |id, _| id.to_s.in?(value_as_array(value)) }.map(&:last).join(' or ') || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    type_columns = {
      es: 'enrolled_in_es',
      ph: 'enrolled_in_ph',
      psh: 'enrolled_in_psh',
      rrh: 'enrolled_in_rrh',
      sh: 'enrolled_in_sh',
      so: 'enrolled_in_so',
      th: 'enrolled_in_th',
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
