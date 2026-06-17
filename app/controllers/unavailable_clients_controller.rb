###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class UnavailableClientsController < ClientsController
  def search_path
    unavailable_client_search_query_path(@search_query)
  end
end
