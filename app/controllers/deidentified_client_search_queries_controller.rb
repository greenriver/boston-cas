###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class DeidentifiedClientSearchQueriesController < DeidentifiedClientsController
  def create
    safe_params = ClientSearchQuery.permit_params(params[:search_form])

    if safe_params[:q].blank?
      redirect_to deidentified_clients_path(sanitized_search_params)
      return
    end

    query = ClientSearchQuery.find_or_create_by_params(safe_params, user: current_user)
    if query.valid?
      redirect_to deidentified_client_search_query_path(sanitized_search_params.merge(id: query.id))
    else
      flash[:error] = 'Search query not valid'
      redirect_to deidentified_clients_path
      return
    end
  end
end
