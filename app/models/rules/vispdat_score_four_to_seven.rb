class Rules::VispdatScoreFourToSeven < Rule
  def clients_that_fit(scope, requirement)
    c_t = Client.arel_table
    if Client.column_names.include?(:vispdat_score.to_s)
      if requirement.positive
        where = c_t[:vispdat_score].gteq(4).and(c_t[:vispdat_score].lteq(7))
      else
        where = c_t[:vispdat_score].lt(4).or(c_t[:vispdat_score].gt(7))
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing, "clients.vispdat_score missing. Cannot check clients against #{self.class}."
    end
  end
end
