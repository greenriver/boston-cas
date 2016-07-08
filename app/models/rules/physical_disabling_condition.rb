class Rules::PhysicalDisablingCondition < Rule
  def clients_that_fit(scope, requirement)
    if physical_disability = Client.arel_table[:physical_disability]
      scope.where(physical_disability: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.physical_disability missing. Cannot check clients against #{self.class}.")
    end
  end
end
