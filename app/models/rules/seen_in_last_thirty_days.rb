class Rules::SeenInLastThirtyDays < Rule
  def clients_that_fit(scope, requirement)
    c_t = Client.arel_table
    if last_seen = c_t[:last_seen]
      if requirement.positive
        where = c_t[:last_seen].gteq( 30.days.ago )
      else
        where = c_t[:last_seen].lt( 30.days.ago )
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.last_seen missing. Cannot check clients against #{self.class}.")
    end
  end
end
