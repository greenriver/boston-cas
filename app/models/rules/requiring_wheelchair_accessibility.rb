class Rules::RequiringWheelchairAccessibility < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:requires_wheelchair_accessibility.to_s)
      if requirement.positive
        where = "requires_wheelchair_accessibility IS TRUE"
      else
        where = "requires_wheelchair_accessibility IS FALSE"
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.requires_wheelchair_accessibility missing. Cannot check clients against #{self.class}.")
    end
  end
end
