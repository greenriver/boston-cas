class ClientMatchesController < MatchListBaseController
  
  before_action :require_admin_or_dnd_staff!
  prepend_before_action :find_client!
  
  private

    def match_scope
      ClientOpportunityMatch
        .accessible_by_user(current_user)
        .where(client_id: @client.id)
    end
    
    def find_client!
      @client = Client.find params[:client_id]
    end
    
    def set_heading
      @heading = "Matches for #{@client.name}"
    end

end