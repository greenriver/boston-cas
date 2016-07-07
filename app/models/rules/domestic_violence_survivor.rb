class Rules::DomesticViolenceSurvivor < Rule
  def clients_that_fit(scope, requirement)
    if domestic_violence = Client.arel_table[:domestic_violence]
      scope.where(domestic_violence: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.domestic_violence missing. Cannot check clients against #{self.class}.")
    end
  end
end
