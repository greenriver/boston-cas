class Rules::IneligibleImmigrant < Rule
  def clients_that_fit(scope, requirement)
    if ineligible_immigrant = Client.arel_table[:ineligible_immigrant]
      scope.where(ineligible_immigrant: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.ineligible_immigrant missing. Cannot check clients against #{self.class}.")
    end
  end
end
