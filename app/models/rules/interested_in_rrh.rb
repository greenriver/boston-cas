class Rules::InterestedInRrh < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:rrh_desired.to_s)
      scope.where(rrh_desired: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.rrh_desired missing. Cannot check clients against #{self.class}.")
    end
  end
end
