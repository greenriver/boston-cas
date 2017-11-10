class Rules::DomesticViolenceSurvivor < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:domestic_violence.to_s)
      scope.where(domestic_violence: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.domestic_violence missing. Cannot check clients against #{self.class}.")
    end
  end
end
