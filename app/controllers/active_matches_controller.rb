class ActiveMatchesController < MatchListBaseController

  private
  
    def match_scope
      ClientOpportunityMatch
        .accessible_by_user(current_user)
        .active
    end
    
    def set_heading
      @heading = 'Matches in Progress'
    end

end