class Rules::OneYearHomeless < Rule
  def clients_that_fit(scope, requirement)
    c_t = Client.arel_table
    if days_homeless = c_t[:days_homeless]
      if requirement.positive
        where = c_t[:days_homeless].gt(365)
      else
        where = c_t[:days_homeless].lteq(365)
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.days_homeless missing. Cannot check clients against #{self.class}.")
    end
  end
end
