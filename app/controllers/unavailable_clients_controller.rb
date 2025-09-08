###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class UnavailableClientsController < ClientsController
  def search_path
    unavailable_client_search_query_path(@search_query)
  end
end
