module Reports
  class ParkedClientsController < ApplicationController

    def index
      base_scope =
        if can_view_all_clients?
          Client.parked
        else
          Client.non_confidential.full_release.parked
        end

      @clients = base_scope
      if params[:q].present?
        @clients = @clients.text_search(params[:q])
      end

      @clients = @clients.
        order(prevent_matching_until: :asc).
        page(params[:page].to_i).per(25)
    end
  end
end
