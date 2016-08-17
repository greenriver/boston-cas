class Rules::DevelopmentalDisability < Rule
  def clients_that_fit(scope, requirement)
    if developmental_disability = Client.arel_table[:developmental_disability]
      scope.where(developmental_disability: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.developmental_disability missing. Cannot check clients against #{self.class}.")
    end
  end
end
