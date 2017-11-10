class Rules::DevelopmentalDisability < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:developmental_disability.to_s)
      scope.where(developmental_disability: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.developmental_disability missing. Cannot check clients against #{self.class}.")
    end
  end
end
