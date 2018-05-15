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
        :should_cancel_other_matches,
        :match_prioritization_id,
      ) 
    end 

    def flash_interpolation_options
      { resource_name: 'Match Route' }
    end
  end
end
