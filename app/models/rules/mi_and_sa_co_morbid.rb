class Rules::MiAndSaCoMorbid < Rule
  def clients_that_fit(scope, requirement)
    if mental_health_problem = Client.arel_table[:mental_health_problem] && substance_abuse_problem = Client.arel_table[:substance_abuse_problem]
      scope.where(mental_health_problem: requirement.positive, substance_abuse_problem: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.mental_health_problem or clients.substance_abuse_problem missing. Cannot check clients against #{self.class}.")
    end
  end
end
