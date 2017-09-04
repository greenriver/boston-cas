class Rules::HousingAuthorityEligible < Rule
  def clients_that_fit(scope, requirement)
    if ha_eligible = Client.arel_table[:ha_eligible]
      scope.where(ha_eligible: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.ha_eligible missing. Cannot check clients against #{self.class}.")
    end
  end
end
