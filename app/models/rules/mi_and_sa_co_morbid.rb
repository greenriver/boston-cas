class Rules::MiAndSaCoMorbid < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:mental_health_problem.to_s) && Client.column_names.include?(:substance_abuse_problem.to_s)
      scope.where(mental_health_problem: requirement.positive, substance_abuse_problem: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.mental_health_problem or clients.substance_abuse_problem missing. Cannot check clients against #{self.class}.")
    end
  end
end
