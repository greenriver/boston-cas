class Rules::AgeGreaterThanSixtyFive < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:date_of_birth.to_s)
      years_ago = Date.today - 65.years
      if requirement.positive
        where = 'date_of_birth <= ?'
      else
        where = 'date_of_birth > ?'
      end
      scope.where(where, years_ago)
    else
      raise RuleDatabaseStructureMissing, "clients.date_of_birth missing. Cannot check clients against #{self.class}."
    end
  end
end
