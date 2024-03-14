###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

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
