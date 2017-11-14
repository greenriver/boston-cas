module Reports
  class ParkedClientsController < ApplicationController
    before_action :authenticate_user!
  	
    def index
      if can_view_all_clients?
        @clients = Client.parked.
          order(prevent_matching_until: :asc).
          page(params[:page].to_i).per(25)
      else
        @clients = Client.non_confidential.parked.
          order(prevent_matching_until: :asc).
          page(params[:page].to_i).per(25)
      end
    end
  end
end
