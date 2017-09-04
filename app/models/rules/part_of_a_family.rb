class Rules::PartOfAFamily < Rule
  def clients_that_fit(scope, requirement)
    if part_of_a_family = Client.arel_table[:part_of_a_family]
      scope.where(part_of_a_family: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.part_of_a_family missing. Cannot check clients against #{self.class}.")
    end
  end
end
