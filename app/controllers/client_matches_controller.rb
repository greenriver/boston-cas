class ClientMatchesController < MatchListBaseController
  
  before_action :require_can_view_all_matches!
  prepend_before_action :find_client!
  
  private

    def match_scope
      ClientOpportunityMatch
        .accessible_by_user(current_user)
        .where(client_id: @client.id)
    end
    
    def find_client!
      @client = Client.find(params[:client_id].to_i)
    end
    
    def set_heading
      @heading = "Matches for #{@client.name}"
    end

end