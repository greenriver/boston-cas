###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Admin
  class RouteReasonAssignmentsController < ApplicationController
    include Admin::ManagesMatchDecisionReasonAssignments

    before_action :require_can_manage_config!
    before_action :load_route
    before_action :load_steps, only: [:edit]

    def edit
      @rows = match_decision_reason_rows(route: @route, decision_type: '')
    end

    def update
      sync_match_decision_reason_assignments!(route: @route, decision_type: '', assignments_params: assignments_params)
      redirect_to edit_admin_match_route_route_reason_assignment_path(@route), notice: 'Route-level reasons updated.'
    end

    private def load_route
      @route = MatchRoutes::Base.find(params[:match_route_id])
    end

    private def load_steps
      @steps = MatchDecisionStep.where(route: @route).sort_by do |step|
        @route.class.match_steps[step.decision_type] || @route.class.match_steps_for_reporting[step.decision_type] || Float::INFINITY
      end
    end

    private def assignments_params
      return {} unless params[:assignments].present?

      params.require(:assignments).permit(decline: {}, cancel: {}).to_h
    end
  end
end
