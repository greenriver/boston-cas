class Rules::InterestedInSetAsides < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:interested_in_set_asides.to_s)
      scope.where(interested_in_set_asides: requirement.positive)
    else
      raise RuleDatabaseStructureMissing, "clients.interested_in_set_asides missing. Cannot check clients against #{self.class}."
    end
  end
end
