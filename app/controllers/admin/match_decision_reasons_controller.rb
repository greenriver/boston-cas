###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Admin
  class MatchDecisionReasonsController < ApplicationController
    before_action :require_can_manage_config!
    before_action :load_match_decision_reason, only: [:edit, :update]

    def index
      @match_decision_reasons = MatchDecisionReasons::Base.order(:name)
    end

    def new
      @match_decision_reason = MatchDecisionReasons::Base.new
    end

    def create
      @match_decision_reason = MatchDecisionReasons::Base.new(match_decision_reason_params)
      if @match_decision_reason.save
        redirect_to admin_match_decision_reasons_path, notice: 'Reason created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @match_decision_reason.update(match_decision_reason_params)
        redirect_to admin_match_decision_reasons_path, notice: 'Reason updated.'
      else
        render :edit
      end
    end

    private def load_match_decision_reason
      @match_decision_reason = MatchDecisionReasons::Base.find(params[:id])
    end

    private def match_decision_reason_params
      params.require(:match_decision_reason).permit(:name, :referral_result, :active)
    end
  end
end
