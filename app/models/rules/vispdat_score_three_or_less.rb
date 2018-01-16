class Rules::VispdatScoreThreeOrLess < Rule
  def clients_that_fit(scope, requirement)
    c_t = Client.arel_table
    if Client.column_names.include?(:vispdat_score.to_s)
      if requirement.positive
        where = c_t[:vispdat_score].lteq(3)
      else
        where = c_t[:vispdat_score].gt(3)
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.vispdat_score missing. Cannot check clients against #{self.class}.")
    end
  end
end
