class Rules::ChronicSubstanceUse < Rule
  def clients_that_fit(scope, requirement)
    if substance_abuse_problem = Client.arel_table[:substance_abuse_problem]
      scope.where(substance_abuse_problem: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.substance_abuse_problem missing. Cannot check clients against #{self.class}.")
    end
  end
end
