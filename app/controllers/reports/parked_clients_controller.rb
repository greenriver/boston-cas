module Reports
  class ParkedClientsController < ApplicationController

    def index

      @clients = Client.parked
      unless can_view_all_clients?
        @clients = @clients.non_confidential.full_release
      end

      if params[:q].present?
        @clients = @clients.text_search(params[:q])
      end

      @clients = @clients.
        order(prevent_matching_until: :asc).
        page(params[:page].to_i).per(25)
    end
  end
end
