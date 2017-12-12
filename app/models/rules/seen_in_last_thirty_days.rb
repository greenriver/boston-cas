class Rules::SeenInLastThirtyDays < Rule
  def clients_that_fit(scope, requirement)
    pc_t = ProjectClient.arel_table
    if last_seen = pc_t[:calculated_last_homeless_night]
      if requirement.positive
        where = pc_t[:calculated_last_homeless_night].gteq( 30.days.ago )
      else
        where = pc_t[:calculated_last_homeless_night].lt( 30.days.ago )
      end
      scope.joins(:project_client).where(where)
    else
      raise RuleDatabaseStructureMissing.new("project_clients.calculated_last_homeless_night is missing. Cannot check clients against #{self.class}.")
    end
  end
end
