class Rules::VerifiedDaysHomeless < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:date_days_homeless_verified.to_s)
      if requirement.positive
        scope.where.not(date_days_homeless_verified: nil)
      else
        scope.where(date_days_homeless_verified: nil)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.date_days_homeless_verified missing. Cannot check clients against #{self.class}.")
    end
  end
end