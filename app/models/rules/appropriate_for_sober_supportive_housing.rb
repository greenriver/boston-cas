class Rules::AppropriateForSoberSupportiveHousing < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:sober_housing.to_s)
      if requirement.positive
        scope.where(sober_housing: true)
      else
        scope.where(sober_housing: false)
      end
    else
      raise RuleDatabaseStructureMissing, "clients.sober_housing missing. Cannot check clients against #{self.class}."
    end
  end
end
