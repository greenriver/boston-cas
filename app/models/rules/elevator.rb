class Rules::Elevator < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:requires_elevator_access.to_s)
      scope.where(requires_elevator_access: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.requires_elevator_access missing. Cannot check clients against #{self.class}.")
    end
  end
end
