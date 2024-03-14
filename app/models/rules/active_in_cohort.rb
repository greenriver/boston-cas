###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::ActiveInCohort < Rule
  def variable_requirement?
    true
  end

  def available_cohorts
    return [] unless Warehouse::Base.enabled?

    Warehouse::Cohort.visible_in_cas.active.pluck(:id, :name, :short_name).
      map do |id, name, short_name|
        label = short_name.presence || name
        [id, label]
      end
  end

  def display_for_variable value
    # Note, we need to jump through a few hoops since variable wasn't designed as a json field
    available_cohorts.select { |id, _| id.to_s.in?(value_as_array(value)) }.map(&:last).join(' or ') || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    if Client.column_names.include?(:active_cohort_ids.to_s)
      if requirement.positive
        where = 'active_cohort_ids @> ANY(ARRAY [?]::jsonb[])'
      else
        where = 'not(active_cohort_ids @> ANY( ARRAY [?]::jsonb[])) OR active_cohort_ids is null'
      end
      scope.where(where, value_as_array(requirement.variable))
    else
      raise RuleDatabaseStructureMissing.new("clients.active_cohort_ids missing. Cannot check clients against #{self.class}.")
    end
  end

  private def value_as_array(value)
    value.split(',')
  end
end
