class Rules::Assylee < Rule
  def clients_that_fit(scope, requirement)
    if assylee = Client.arel_table[:assylee]
      scope.where(assylee: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.assylee missing. Cannot check clients against #{self.class}.")
    end
  end
end
