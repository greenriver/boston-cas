###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::EnrolledInHmisProject < Rule
  def variable_requirement?
    true
  end

  def available_projects
    @available_projects ||= if Warehouse::Base.enabled?
      Warehouse::Project.joins(:organization).preload(:organization).map do |project|
        label = "#{project.ProjectName} << #{project.organization.OrganizationName}"
        [project.id, label]
      end
    else
      []
    end
  end

  def display_for_variable value
    # Note, we need to jump through a few hoops since variable wasn't designed as a json field
    available_projects.select { |id, _| id.to_s.in?(value_as_array(value)) }.map(&:last).join(' or ') || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.enrolled_project_ids missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:enrolled_project_ids.to_s)

    if requirement.positive
      where = 'enrolled_project_ids @> ANY(ARRAY [?]::jsonb[])'
    else
      where = 'not(enrolled_project_ids @> ANY( ARRAY [?]::jsonb[])) OR enrolled_project_ids is null'
    end
    scope.where(where, value_as_array(requirement.variable))
  end

  private def value_as_array(value)
    value.split(',')
  end
end
