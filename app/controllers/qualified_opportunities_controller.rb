class QualifiedOpportunitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_view_all_clients!
  before_action :require_can_edit_all_clients!, only: [:update]
  before_action :set_client
  before_action :set_opportunity, only: [:update]

  def index
    @client_active_opportunity_ids = @client.active_matches.
      joins(:opportunity).
      pluck(Opportunity.arel_table[:id].as('id').to_sql)
    @opportunities = opportunity_scope.select do |opportunity|
      opportunity.matches_client?(@client) && ! @client_active_opportunity_ids.include?(opportunity.id)
    end
  end

  def update
    if active_match = @opportunity.active_match
      active_match.poached!
    end

    universe_state = {
      requirements: @opportunity.requirements_for_archive,
      services: @opportunity.services_for_archive,
      opportunity: @opportunity.opportunity_details.opportunity_for_archive,
      client: @client.prepare_for_archive,
    }
    match = @client.candidate_matches.create(
      opportunity: @opportunity, 
      client: @client, 
      universe_state: @universe_state
    )
    match.activate!
    redirect_to match_path match
  end

  def set_client
    @client = Client.find params[:client_id].to_i
  end

  def set_opportunity
    @opportunity = opportunity_scope.find params[:id].to_i
  end

  def opportunity_scope
    Opportunity.available_for_poaching.joins(sub_program: :program).
      order(Program.arel_table[:name].asc, SubProgram.arel_table[:name].asc, id: :asc)
  end
end