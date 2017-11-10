class Rules::Veteran < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:veteran.to_s)
      scope.where(veteran: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.veteran missing. Cannot check clients against #{self.class}.")
    end
  end
end
