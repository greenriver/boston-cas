class Rules::UsCitizen < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:us_citizen.to_s)
      scope.where(us_citizen: requirement.positive)
    else
      raise RuleDatabaseStructureMissing, "clients.us_citizen missing. Cannot check clients against #{self.class}."
    end
  end
end
