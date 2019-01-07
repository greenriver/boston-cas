class OpportunityMatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_see_alternate_matches!
  before_action :require_can_edit_all_clients!, only: [:update]
  before_action :set_heading

  prepend_before_action :find_opportunity!

  def index
    clients_for_route = Client.available_for_matching(@opportunity.match_route)
    @matches = @opportunity.matching_clients(clients_for_route).page(params[:page]).per(25)
    @sub_program = @opportunity.sub_program
    @program = @sub_program.program
  end

  def closed
    @matches = @opportunity.closed_matches.page(params[:page]).per(25)
    @sub_program = @opportunity.sub_program
    @program = @sub_program.program
  end

  def update
    client = Client.find params[:id].to_i

    if active_match = @opportunity.active_match
      MatchEvents::DecisionAction.create(match_id: active_match.id, decision_id: active_match.current_decision.id, action: :canceled, contact_id: current_user.contact&.id)
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
    redirect_to match_path match
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
      @heading = "Eligible Clients for Vacancy"
    end

end
