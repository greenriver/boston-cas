###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Reports
  class ParkedClientsController < ApplicationController
    before_action :authenticate_user!
  	
    def index
      if can_view_all_clients?
        clients = parked_scope
      else
        clients = parked_scope.non_confidential.full_release
      end
      @clients = clients.
        order(prevent_matching_until: :asc).
        page(params[:page].to_i).per(25)
    end

    def parked_scope
      Client.accessible_by_user(current_user).parked
    end
  end
end
