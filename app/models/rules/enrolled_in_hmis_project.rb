class Rules::EnrolledInHmisProject < Rule
  def variable_requirement?
    true
  end

  def available_projects
    @available_projects ||= if Warehouse::Base.enabled?
      Warehouse::Project.joins(:organization).map do |project|
        label = "#{project.ProjectName} << #{project.organization.OrganizationName}"
        [project.id, label]
      end
    else
      []
    end
  end

  def display_for_variable value
    available_projects.to_h.try(:[], value.to_i) || value
  end

  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:enrolled_project_ids.to_s)
      if requirement.positive
        where = 'enrolled_project_ids @> ?'
      else
        where = 'not(enrolled_project_ids @> ?) OR enrolled_project_ids is null'
      end
      scope.where(where, requirement.variable.to_s)
    else
      raise RuleDatabaseStructureMissing.new("clients.enrolled_project_ids missing. Cannot check clients against #{self.class}.")
    end
  end
end
