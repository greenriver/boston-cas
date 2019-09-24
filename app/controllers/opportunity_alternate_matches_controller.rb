###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class OpportunityAlternateMatchesController < MatchListBaseController

  before_action :require_can_see_alternate_matches!
  prepend_before_action :find_opportunity!

  private

    def match_scope
      raise 'Deprecated!'
      ClientOpportunityMatch
        .accessible_by_user(current_user)
        .candidate
        .where(opportunity_id: @opportunity.id)
        .joins(:client)
    end

    def find_opportunity!
      @opportunity = Opportunity.find params[:opportunity_id]
    end

    def set_heading
      @heading = "Prioritized Clients for Opportunity ##{@opportunity.id}"
    end

end