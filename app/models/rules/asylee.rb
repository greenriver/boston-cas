class Rules::Asylee < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:asylee.to_s)
      scope.where(asylee: requirement.positive)
    else
      raise RuleDatabaseStructureMissing, "clients.asylee missing. Cannot check clients against #{self.class}."
    end
  end
end
