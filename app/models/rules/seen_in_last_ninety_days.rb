class Rules::SeenInLastNinetyDays < Rule
  def clients_that_fit(scope, requirement)
    c_t = Client.arel_table
    if last_seen = c_t[:calculated_last_homeless_night]
      if requirement.positive
        where = c_t[:calculated_last_homeless_night].gteq( 90.days.ago )
      else
        where = c_t[:calculated_last_homeless_night].lt( 90.days.ago )
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("calculated_last_homeless_night is missing. Cannot check clients against #{self.class}.")
    end
  end
end
