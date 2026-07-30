###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Admin
  class MatchDecisionStepsController < ApplicationController
    include Admin::ManagesMatchDecisionReasonAssignments

    before_action :require_can_manage_config!
    before_action :load_route
    before_action :load_step

    def edit
      @rows = match_decision_reason_rows(route: @route, decision_type: @step.decision_type)
    end

    def update
      @step.update(default_referral_result_params)
      kinds = @step.supports_declines? ? ['decline', 'cancel'] : ['cancel']
      sync_match_decision_reason_assignments!(route: @route, decision_type: @step.decision_type, assignments_params: assignments_params, kinds: kinds)
      redirect_to edit_admin_match_route_match_decision_step_path(@route, @step), notice: 'Step reasons updated.'
    end

    private def load_route
      @route = MatchRoutes::Base.find(params[:match_route_id])
    end

    private def load_step
      @step = MatchDecisionStep.where(route: @route).find(params[:id])
    end

    private def default_referral_result_params
      params.fetch(:match_decision_step, {}).permit(:default_referral_result)
    end

    private def assignments_params
      return {} unless params[:assignments].present?

      params.require(:assignments).permit(decline: {}, cancel: {}).to_h
    end
  end
end
