class Rules::Asylee < Rule
  def clients_that_fit(scope, requirement)
    if asylee = Client.arel_table[:asylee]
      scope.where(asylee: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.asylee missing. Cannot check clients against #{self.class}.")
    end
  end
end
