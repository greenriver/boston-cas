class Rules::MiAndSaCoMorbid < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:mental_health_problem.to_s) && Client.column_names.include?(:substance_abuse_problem.to_s)
      if requirement.positive
        scope.where(mental_health_problem: true, substance_abuse_problem: true)
      else
        c_t = Client.arel_table
        scope.where(c_t[:mental_health_problem].eq(false).or(c_t[:substance_abuse_problem].eq(false)))
      end
    else
      raise RuleDatabaseStructureMissing, "clients.mental_health_problem or clients.substance_abuse_problem missing. Cannot check clients against #{self.class}."
    end
  end
end
