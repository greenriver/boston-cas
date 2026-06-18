###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class ClientClosedMatchesController < ClientMatchesController
  def active_tab
    'history'
  end

  private def match_scope
    ClientOpportunityMatch.
      accessible_by_user(current_user).
      closed.
      where(client_id: @client.id).
      order(updated_at: :desc, created_at: :desc, id: :desc)
  end
end
