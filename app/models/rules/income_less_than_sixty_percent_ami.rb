class Rules::IncomeLessThanSixtyPercentAmi < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:income_total_monthly.to_s)
      ami = 41220/12 #60% AMI
      if requirement.positive
        where = "income_total_monthly < ?"
      else
        where = "income_total_monthly >= ?"
      end
      scope.where(where, ami)
    else
      raise RuleDatabaseStructureMissing.new("clients.income_total_monthly missing. Cannot check clients against #{self.class}.")
    end
  end
end
