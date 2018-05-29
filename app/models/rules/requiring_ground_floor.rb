class Rules::RequiringGroundFloor < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:requires_ground_floor.to_s)
      if requirement.positive
        where = "requires_ground_floor IS TRUE"
      else
        where = "requires_ground_floor IS FALSE"
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.requires_ground_floor missing. Cannot check clients against #{self.class}.")
    end
  end
end
