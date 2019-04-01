class Rules::InterestedInYouthRrh < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:youth_rrh_desired.to_s)
      scope.where(youth_rrh_desired: requirement.positive)
    else
      raise RuleDatabaseStructureMissing, "clients.youth_rrh_desired missing. Cannot check clients against #{self.class}."
    end
  end
end
