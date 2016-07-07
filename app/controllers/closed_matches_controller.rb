class ClosedMatchesController < MatchListBaseController
  
  before_action :require_admin_or_dnd_staff!
  
  private

    def match_scope
      ClientOpportunityMatch
        .accessible_by_user(current_user)
        .closed
    end
    
    def set_heading
      @heading = 'Closed Matches'
    end

end