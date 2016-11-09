module Reports
  class ParkedClientsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_can_view_reports!
  	
    def index
      @clients = Client.parked
        .page(params[:page].to_i).per(25)
    end
  end
end
