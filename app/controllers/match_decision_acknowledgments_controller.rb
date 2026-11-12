###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class MatchDecisionAcknowledgmentsController < ApplicationController
  include HasMatchAccessContext

  skip_before_action :authenticate_user!
  before_action :require_match_access_context!
  before_action :find_match!
  before_action :find_decision!
  before_action :authorize_decision!

  delegate :current_contact, :match_scope, to: :access_context

  def create
    if @decision.update status: 'acknowledged'
      @decision.record_action_event! contact: current_contact
      @decision.run_status_callback!(user: current_user)
      head :ok
    else
      head :bad_request
    end
  end

  private def find_match!
    @match = match_scope.find params[:match_id]
  end

  private def find_decision!
    @decision = @match.decision_from_param params[:decision_id]
    head :not_found unless @decision
  end

  private def authorize_decision!
    return if @decision.accessible_by?(current_contact) &&
      @decision.editable? &&
      @decision.status.in?(['pending', 'expiration_update'])

    head :forbidden
  end
end
