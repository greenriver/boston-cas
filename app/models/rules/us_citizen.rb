class Rules::UsCitizen < Rule
  def clients_that_fit(scope, requirement)
    if us_citizen = Client.arel_table[:us_citizen]
      scope.where(us_citizen: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.us_citizen missing. Cannot check clients against #{self.class}.")
    end
  end
end
