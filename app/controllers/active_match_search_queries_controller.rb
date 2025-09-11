###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class ActiveMatchSearchQueriesController < ActiveMatchesController
  def create
    safe_params = ClientSearchQuery.permit_params(params)

    if safe_params[:q].blank?
      redirect_to active_matches_path(sanitized_search_params)
      return
    end

    query = ClientSearchQuery.find_or_create_by_params(safe_params, user: current_user)
    if query.valid?
      redirect_to active_match_search_query_path(sanitized_search_params.merge(id: query.id, current_route: @current_route_name))
    else
      flash[:error] = 'Search query not valid'
      redirect_to active_matches_path
      return
    end
  end
end
