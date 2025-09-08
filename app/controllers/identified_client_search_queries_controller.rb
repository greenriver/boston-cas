###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class IdentifiedClientSearchQueriesController < IdentifiedClientsController
  def create
    safe_params = ClientSearchQuery.permit_params(params[:search_form])
    query = ClientSearchQuery.find_or_create_by_params(safe_params, user: current_user)
    if query.valid?
      redirect_to identified_client_search_query_path(id: query.id)
    else
      flash[:error] = 'Search query not valid'
      redirect_to identified_clients_path
      return
    end
  end
end
