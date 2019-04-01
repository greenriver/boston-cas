class Rules::Income < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:income_total_monthly.to_s)
      c_t = Client.arel_table
      if requirement.positive
        where = c_t[:income_total_monthly].gt(0)
      else
        where = c_t[:income_total_monthly].eq(0).or(c_t[:income_total_monthly].eq(nil))
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing, "clients.income_total_monthly missing. Cannot check clients against #{self.class}."
    end
  end
end
