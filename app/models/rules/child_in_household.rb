class Rules::ChildInHousehold < Rule
  def clients_that_fit(scope, requirement)
    if child_in_household = Client.arel_table[:child_in_household]
      scope.where(child_in_household: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.child_in_household missing. Cannot check clients against #{self.class}.")
    end
  end
end
