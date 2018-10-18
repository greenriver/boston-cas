class Rules::VerifiedDisability < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:disability_verified_on.to_s)
      if requirement.positive
        scope.where.not(disability_verified_on: nil)
      else
        scope.where(disability_verified_on: nil)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.disability_verified_on missing. Cannot check clients against #{self.class}.")
    end
  end
end
