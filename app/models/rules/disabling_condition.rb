class Rules::DisablingCondition < Rule
  def clients_that_fit(scope, requirement)
    if disabling_condition = Client.arel_table[:disabling_condition]
      scope.where(disabling_condition: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.disabling_condition missing. Cannot check clients against #{self.class}.")
    end
  end
end
