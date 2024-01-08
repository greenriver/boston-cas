class Rules::HousingBarrier < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:housing_barrier.to_s)
      scope.where(housing_barrier: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.housing_barrier missing. Cannot check clients against #{self.class}.")
    end
  end
end