class Rules::MethProductionConviction < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:meth_production_conviction.to_s)
      scope.where(meth_production_conviction: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.meth_production_conviction missing. Cannot check clients against #{self.class}.")
    end
  end
end
