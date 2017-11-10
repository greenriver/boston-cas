class Rules::HuesEligible < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:hues_eligible.to_s)
      scope.where(hues_eligible: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.hues_eligible missing. Cannot check clients against #{self.class}.")
    end
  end
end
