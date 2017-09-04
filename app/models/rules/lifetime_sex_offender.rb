class Rules::LifetimeSexOffender < Rule
  def clients_that_fit(scope, requirement)
    if lifetime_sex_offender = Client.arel_table[:lifetime_sex_offender]
      scope.where(lifetime_sex_offender: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.lifetime_sex_offender missing. Cannot check clients against #{self.class}.")
    end
  end
end
