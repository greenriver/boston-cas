class Rules::MentalHealthEligible < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:mental_health_problem.to_s)
      scope.where(mental_health_problem: requirement.positive)
    else
      raise RuleDatabaseStructureMissing, "clients.mental_health_problem missing. Cannot check clients against #{self.class}."
    end
  end
end
