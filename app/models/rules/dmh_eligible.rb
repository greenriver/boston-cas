class Rules::DmhEligible < Rule
  def clients_that_fit(scope, requirement)
    if dmh_eligible = Client.arel_table[:dmh_eligible]
      scope.where(dmh_eligible: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.dmh_eligible missing. Cannot check clients against #{self.class}.")
    end
  end
end
