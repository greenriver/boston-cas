###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
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