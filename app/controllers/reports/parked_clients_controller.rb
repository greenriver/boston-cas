###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Reports
  class ParkedClientsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_routes
    before_action :set_route

    def index
      @active_tab = params[:tab] || route_to_html_id(@routes.first)
      clients = parked_scope
      clients = clients.non_confidential.full_release unless can_view_all_clients?

      @clients = clients.
        joins(:unavailable_as_candidate_fors).
        order('unavailable_as_candidate_fors.expires_at asc').
        page(params[:page].to_i).per(25)
    end

    def parked_scope
      Client.accessible_by_user(current_user).unavailable_in(@route)
    end

    private def set_routes
      @routes = MatchRoutes::Base.available
    end

    private def set_route
      @route = route_from_tab(params[:tab])
    end

    def route_to_html_id(route)
      route.title.parameterize.dasherize
    end
    helper_method :route_to_html_id

    private def route_from_tab(tab_label=nil)
      return @routes.first unless tab_label.present?

      @routes.detect do |route|
        route_to_html_id(route) == tab_label
      end || @routes.first
    end
  end
end
