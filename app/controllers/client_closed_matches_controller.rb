class ClientClosedMatchesController < ClientMatchesController
  def active_tab
    'history'
  end

  private def match_scope
    ClientOpportunityMatch.
      accessible_by_user(current_user).
      closed.
      where(client_id: @client.id)
  end
end