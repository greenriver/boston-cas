###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class MatchDecisionAcknowledgmentsController < ApplicationController
  include HasMatchAccessContext

  skip_before_action :authenticate_user!
  before_action :require_match_access_context!
  before_action :find_match!
  before_action :find_decision!
  before_action :authorize_decision!

  delegate :current_contact,
    :match_scope,
    to: :access_context

  def create
    if @decision.update status: 'acknowledged'
      @decision.record_action_event! contact: current_contact
      @decision.run_status_callback!
      head :ok
    else
      head :bad_request
    end
  end

  private

    def find_match!
      @match = match_scope.find params[:match_id]
    end

    def find_decision!
      @decision = @match.decision_from_param params[:decision_id]
    end

    def authorize_decision!
      # TODO ensure that the current contact can authorize this decision
    end

end
