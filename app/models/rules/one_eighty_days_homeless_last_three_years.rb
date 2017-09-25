class Rules::OneEightyDaysHomelessLastThreeYears < Rule
  def clients_that_fit(scope, requirement)
    c_t = Client.arel_table
    if days_homeless_in_last_three_years = c_t[:days_homeless_in_last_three_years]
      if requirement.positive
        where = c_t[:days_homeless_in_last_three_years].gt(180)
      else
        where = c_t[:days_homeless_in_last_three_years].lteq(180)
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.days_homeless_in_last_three_years missing. Cannot check clients against #{self.class}.")
    end
  end
end
