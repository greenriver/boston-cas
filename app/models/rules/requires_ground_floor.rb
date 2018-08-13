class Rules::RequiresGroundFloor < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:requires_ground_floor.to_s)
      if requirement.positive
        scope.where(requires_ground_floor: true)
      else
        scope.where(requires_ground_floor: false)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.requires_ground_floor missing. Cannot check clients against #{self.class}.")
    end
  end
end
