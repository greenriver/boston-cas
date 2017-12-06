class Rules::IncomeLessThanFiftyPercentAmi < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:income_total_monthly.to_s)
      c_t = Client.arel_table
      ami = Config.get(:ami)
      ami_partial = (ami * 0.5) / 12 #50% AMI
      if requirement.positive
        where = c_t[:income_total_monthly].lt(ami_partial).
          or(c_t[:income_total_monthly].eq(nil))
      else
        where = c_t[:income_total_monthly].gteq(ami_partial)
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.income_total_monthly missing. Cannot check clients against #{self.class}.")
    end
  end
end
