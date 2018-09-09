class Rules::GroundFloor < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:requires_ground_floor.to_s)
      scope.where(requires_ground_floor: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.requires_ground_floor missing. Cannot check clients against #{self.class}.")
    end
  end
end
