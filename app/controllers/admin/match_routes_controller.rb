###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Admin
  class MatchRoutesController < ApplicationController
    before_action :require_can_manage_config!
    before_action :load_match_route, only: [:edit, :update]
    before_action :load_steps, only: [:edit]

    def index
      @routes = MatchRoutes::Base.all.order(id: :desc)
      @active_routes, @inactive_routes = @routes.to_a.partition(&:active)
    end

    def edit
    end

    def update
      @route.update(update_params)
      respond_with(@route, location: admin_match_routes_path)
    end

    def load_match_route
      @route = MatchRoutes::Base.find params[:id].to_i
    end

    private def load_steps
      @steps = MatchDecisionStep.where(route: @route).sort_by do |step|
        @route.class.match_steps[step.decision_type] || @route.class.match_steps_for_reporting[step.decision_type] || Float::INFINITY
      end
    end

    def update_params
      params.require(:match_route).permit(
        :active,
        :contacts_editable_by_hsa,
        :should_activate_match,
        :allow_multiple_active_matches,
        :should_cancel_other_matches,
        :should_prevent_multiple_matches_per_client,
        :default_shelter_agency_contacts_from_project_client,
        :match_prioritization_id,
        :tag_id,
        :show_default_contact_types,
        :send_notifications,
        :stalled_interval,
        :housing_type,
        :send_notes_by_default,
        :expects_roi,
        :show_referral_source,
        :show_move_in_date,
        :show_address_field,
        prioritized_client_columns: [],
        routes_parked_on_active_match: [],
        routes_parked_on_successful_match: [],
      )
    end

    def flash_interpolation_options
      { resource_name: 'Match Route' }
    end
  end
end
