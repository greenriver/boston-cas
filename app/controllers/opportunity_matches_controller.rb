class OpportunityMatchesController < MatchListBaseController

  before_action :require_can_view_all_matches!
  prepend_before_action :find_opportunity!

  def index
    if params[:show_only_available].present?
      clients_for_route = Client.available_for_matching(@opportunity.match_route);
    else
      clients_for_route = Client.all
    end

    @opportunity.requirements_with_inherited.each do |requirement|
      clients_for_route = clients_for_route.merge(requirement.clients_that_fit(clients_for_route))
    end
    @matches = clients_for_route.merge(Client.prioritized(match_route: @opportunity.match_route))
  end

  def update
    client = Client.find params[:client_id].to_i

    if active_match = @opportunity.active_match
      active_match.poached!
    end

    universe_state = {
        requirements: @opportunity.requirements_for_archive,
        services: @opportunity.services_for_archive,
        opportunity: @opportunity.opportunity_details.opportunity_for_archive,
        client: client.prepare_for_archive,
    }
    match = client.candidate_matches.create(
        opportunity: @opportunity,
        client: client,
        universe_state: universe_state
    )
    match.activate!
    redirect_to opportunity_matches_path
  end

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
