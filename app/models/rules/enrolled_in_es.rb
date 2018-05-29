class Rules::EnrolledInEs < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:enrolled_in_es.to_s)
      scope.where(enrolled_in_es: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.enrolled_in_es missing. Cannot check clients against #{self.class}.")
    end
  end
end
