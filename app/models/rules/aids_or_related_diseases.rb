class Rules::AidsOrRelatedDiseases < Rule
  def clients_that_fit(scope, requirement)
    ct = Client.arel_table
    if hiv_aids = ct[:hiv_aids] && ct[:hiv_positive]
      scope.where(ct[:hiv_aids].eq(requirement.positive).or(ct[:hiv_positive].eq(requirement.positive)))
    else
      raise RuleDatabaseStructureMissing.new("clients.hiv_aids missing. Cannot check clients against #{self.class}.")
    end
  end
end
