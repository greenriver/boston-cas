class Rules::HuesEligible < Rule
  def clients_that_fit(scope, requirement)
    if hues_eligible = Client.arel_table[:hues_eligible]
      scope.where(hues_eligible: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.hues_eligible missing. Cannot check clients against #{self.class}.")
    end
  end
end
