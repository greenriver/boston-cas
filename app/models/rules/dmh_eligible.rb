class Rules::DmhEligible < Rule
  def clients_that_fit(scope, requirement)
    if mental_health_problem = Client.arel_table[:mental_health_problem]
      scope.where(mental_health_problem: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.mental_health_problem missing. Cannot check clients against #{self.class}.")
    end
  end
end
