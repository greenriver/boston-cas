###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class MatchClientDetailsController < ApplicationController
  include HasMatchAccessContext
  include AjaxModalRails::Controller

  skip_before_action :authenticate_user!
  before_action :require_match_access_context!

  before_action :set_match
  before_action :set_client

  def show
    @matches = match_history_scope
  end

  private

    def set_match
      @match = match_scope.find params[:match_id]
    end

    def set_client
      @client = @match.client
    end

    def match_history_scope
      ClientOpportunityMatch
        .closed
        .where(client_id: @client.id)
    end

end
