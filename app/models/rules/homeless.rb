class Rules::Homeless < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:available.to_s)
      scope.where(available: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.available missing. Cannot check clients against #{self.class}.")
    end
  end
  
  def always_apply?
    true
  end
end
