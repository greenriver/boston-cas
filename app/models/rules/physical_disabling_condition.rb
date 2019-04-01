class Rules::PhysicalDisablingCondition < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:physical_disability.to_s)
      scope.where(physical_disability: requirement.positive)
    else
      raise RuleDatabaseStructureMissing, "clients.physical_disability missing. Cannot check clients against #{self.class}."
    end
  end
end
