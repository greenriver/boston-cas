class Rules::AidsOrRelatedDiseases < Rule
  def clients_that_fit(scope, requirement)
    if hiv_aids = Client.arel_table[:hiv_aids]
      scope.where(hiv_aids: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.hiv_aids missing. Cannot check clients against #{self.class}.")
    end
  end
end
