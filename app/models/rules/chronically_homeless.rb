class Rules::ChronicallyHomeless < Rule
  def clients_that_fit(scope, requirement)
    if chronic_homeless = Client.arel_table[:chronic_homeless]
      scope.where(chronic_homeless: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.chronic_homeless missing. Cannot check clients against #{self.class}.")
    end
  end
  
  def always_apply?
    false
  end
end
