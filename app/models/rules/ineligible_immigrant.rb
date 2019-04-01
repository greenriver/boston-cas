class Rules::IneligibleImmigrant < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:ineligible_immigrant.to_s)
      scope.where(ineligible_immigrant: requirement.positive)
    else
      raise RuleDatabaseStructureMissing, "clients.ineligible_immigrant missing. Cannot check clients against #{self.class}."
    end
  end
end
