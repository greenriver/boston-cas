class Rules::VaEligible < Rule
  def clients_that_fit(scope, requirement)
    if va_eligible = Client.arel_table[:va_eligible]
      scope.where(va_eligible: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.va_eligible missing. Cannot check clients against #{self.class}.")
    end
  end
end
