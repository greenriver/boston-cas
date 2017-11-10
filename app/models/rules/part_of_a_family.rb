class Rules::PartOfAFamily < Rule
  def clients_that_fit(scope, requirement)
    if family_member = Client.arel_table[:family_member]
      scope.where(family_member: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.family_member missing. Cannot check clients against #{self.class}.")
    end
  end
end
