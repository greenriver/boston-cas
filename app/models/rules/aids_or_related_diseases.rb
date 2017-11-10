class Rules::AidsOrRelatedDiseases < Rule
  def clients_that_fit(scope, requirement)
    c_t = Client.arel_table
    if hiv_aids = Client.column_names.include?(:hiv_aids.to_s) && Client.column_names.include?(:hiv_positive.to_s)
      scope.where(c_t[:hiv_aids].eq(requirement.positive).or(c_t[:hiv_positive].eq(requirement.positive)))
    else
      raise RuleDatabaseStructureMissing.new("clients.hiv_aids missing. Cannot check clients against #{self.class}.")
    end
  end
end
