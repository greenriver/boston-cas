class Rules::Homeless < Rule
  def clients_that_fit(scope, requirement)
    if homeless = Client.arel_table[:available]
      scope.where(available: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.available missing. Cannot check clients against #{self.class}.")
    end
  end
  
  def always_apply?
    true
  end
end
