class Rules::ServiceNeed < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:service_need.to_s)
      scope.where(service_need: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.service_need missing. Cannot check clients against #{self.class}.")
    end
  end
end