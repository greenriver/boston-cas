class OpportunityMatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_see_alternate_matches!
  before_action :require_can_edit_all_clients!, only: [:update]
  before_action :set_heading

  prepend_before_action :find_opportunity!

  def index
    clients_for_route = Client.available_for_matching(@opportunity.match_route)
    @actives = @opportunity.active_matches.map { |match| match.client }
    @availables = @opportunity.matching_clients(clients_for_route)
    @matches = Kaminari.paginate_array(@actives + @availables).page(params[:page]).per(25)
    @sub_program = @opportunity.sub_program
    @program = @sub_program.program
  end

  def closed
    @matches = @opportunity.closed_matches.page(params[:page]).per(25)
    @sub_program = @opportunity.sub_program
    @program = @sub_program.program
  end

  def create
    client_ids_to_activate = params[:checkboxes].reject { | key, value | value != "1" }.keys.map(&:to_i)
    client_ids_to_activate.each do | client_id |
      matches = ClientOpportunityMatch.where(client_id: client_id, opportunity_id: @opportunity, closed: false)
      if matches.count == 0
        match = create_match(client_id)
      else
        match = matches.first # should never be more than one
      end
      match.activate!
    end
    redirect_to opportunity_matches_path(@opportunity)
  end

  def update
    client_id =  params[:id].to_i

    if active_match = @opportunity.active_match
      MatchEvents::DecisionAction.create(match_id: active_match.id, decision_id: active_match.current_decision.id, action: :canceled, contact_id: current_user.contact&.id)
      active_match.poached!
    end

    match = create_match(client_id)

    match.activate!
    redirect_to match_path match
  end

  def create_match(client_id)
    client = Client.find(client_id)

    universe_state = {
        requirements: @opportunity.requirements_for_archive,
        services: @opportunity.services_for_archive,
        opportunity: @opportunity.opportunity_details.opportunity_for_archive,
        client: client.prepare_for_archive,
    }
    client.candidate_matches.create(
        opportunity: @opportunity,
        client: client,
        universe_state: universe_state
    )
  end

  def priority_label
    @opportunity.match_route.match_prioritization.title
  end
  helper_method :priority_label

  def priority_value(client)
    client.send(@opportunity.match_route.match_prioritization.column_name)
  end
  helper_method :priority_value

  def match_routes(client)
    counts = client.client_opportunity_matches.joins(:program, :match_route).group(:type).count
    counts.map do | key, value |
      [ key.constantize.new.title, value ]
    end
  end
  helper_method :match_routes

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
