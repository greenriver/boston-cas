module Reports
  class ParkedClientsController < ApplicationController
    before_action :authenticate_user!

    def index
      base_scope =
        if can_view_all_clients?
          Client.parked
        else
          Client.non_confidential.full_release.parked
        end

      @clients =
          if params[:q].present?
            base_scope.text_search(params[:q])
          else
            base_scope
          end

      @clients = @clients.
          order(prevent_matching_until: :asc).
          page(params[:page].to_i).per(25)
    end
  end
end
