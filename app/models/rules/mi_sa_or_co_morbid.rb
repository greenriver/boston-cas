class Rules::MiSaOrCoMorbid < Rule
  def clients_that_fit(scope, requirement)
    c_arel = Client.arel_table
    if mental_health_problem = c_arel[:mental_health_problem] && substance_abuse_problem = c_arel[:substance_abuse_problem]
      scope.where(c_arel[:mental_health_problem].eq(requirement.positive).or(c_arel[:substance_abuse_problem].eq(requirement.positive)))
    else
      raise RuleDatabaseStructureMissing.new("clients.mental_health_problem or clients.substance_abuse_problem missing. Cannot check clients against #{self.class}.")
    end
  end
end
