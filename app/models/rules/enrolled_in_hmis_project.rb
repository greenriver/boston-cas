class Rules::EnrolledInHmisProject < Rule
  def variable_requirement?
    true
  end

  def available_projects
    Warehouse::Project.pluck(:id, :ProjectName)
  end

  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:enrolled_project_ids.to_s)
      if requirement.positive
        where = 'enrolled_project_ids @> ?'
      else
        where = 'not(enrolled_project_ids @> ?) OR enrolled_project_ids is null'
      end
      scope.where(where, requirement.variable.to_i)
    else
      raise RuleDatabaseStructureMissing.new("clients.enrolled_project_ids missing. Cannot check clients against #{self.class}.")
    end
  end
end
