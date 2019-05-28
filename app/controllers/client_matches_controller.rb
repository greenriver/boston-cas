class ClientMatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_view_all_matches!
  before_action :find_client!

  def index
    @matches = match_scope.
      references(:client).
      includes(:client).
      preload(:client, :opportunity, :decisions).
      page(params[:page]).per(25)
  end


  def active_tab
    'matches'
  end
  helper_method :active_tab

  private

    def match_scope
      ClientOpportunityMatch.
        accessible_by_user(current_user).
        open.
        where(client_id: @client.id)
    end

    def find_client!
      @client = Client.find(params[:client_id].to_i)
    end

    def show_links_to_matches?
      true
    end
    helper_method :show_links_to_matches?
end