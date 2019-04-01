class Rules::SsvfEligible < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:ssvf_eligible.to_s)
      scope.where(ssvf_eligible: requirement.positive)
    else
      raise RuleDatabaseStructureMissing, "clients.ssvf_eligible missing. Cannot check clients against #{self.class}."
    end
  end
end
