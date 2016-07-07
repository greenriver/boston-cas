class Rules::AgeGreaterThanFifty < Rule
  def clients_that_fit(scope, requirement)
    if date_of_birth = Client.arel_table[:date_of_birth]
      years_ago = Date.today - 50.years
      if requirement.positive
        where = "date_of_birth < ?"
      else
        where = "date_of_birth >= ?"
      end
      scope.where(where, years_ago)
    else
      raise RuleDatabaseStructureMissing.new("clients.hiv_aids missing. Cannot check clients against #{self.class}.")
    end
  end
end
