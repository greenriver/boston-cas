class OpportunityMatchesController < MatchListBaseController

  before_action :require_can_view_all_matches!
  prepend_before_action :find_opportunity!

  private

    def match_scope
      ClientOpportunityMatch
        .accessible_by_user(current_user)
        .where(opportunity_id: @opportunity.id)
    end

    def find_opportunity!
      @opportunity = Opportunity.find params[:opportunity_id]
    end

    def set_heading
      @heading = "Matches for Opportunity ##{@opportunity.id}"
    end

end
