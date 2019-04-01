class Rules::VaEligible < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:va_eligible.to_s)
      scope.where(va_eligible: requirement.positive)
    else
      raise RuleDatabaseStructureMissing, "clients.va_eligible missing. Cannot check clients against #{self.class}."
    end
  end
end
