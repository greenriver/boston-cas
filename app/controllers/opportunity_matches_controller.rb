class OpportunityMatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_see_alternate_matches!
  before_action :require_can_edit_all_clients!, only: [:update]
  before_action :set_heading

  prepend_before_action :find_opportunity!

  def index
    @active = :show_available_clients
    if params[:show_all_clients].present?
      @active = :show_all_clients
      clients_for_route = Client.all
    else
      clients_for_route = Client.available_for_matching(@opportunity.match_route)
    end

    @matches = @opportunity.matching_clients(clients_for_route).page(params[:page]).per(25)

    @sub_program = @opportunity.sub_program
    @program = @sub_program.program
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
      @heading = "Matches for Opportunity ##{@opportunity.id}"
    end

end
