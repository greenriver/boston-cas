###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Admin
  class MatchRoutesController < ApplicationController
    before_action :require_can_manage_config!
    before_action :load_match_route, only: [:edit, :update]

    def index
      @routes = MatchRoutes::Base.all.order("id DESC")
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
      )
    end

    def flash_interpolation_options
      { resource_name: 'Match Route' }
    end
  end
end
