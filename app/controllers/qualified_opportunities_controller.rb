###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class QualifiedOpportunitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :some_clients_viewable!
  before_action :some_clients_editable!, only: [:update]
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
    if @opportunity.match_route.should_cancel_other_matches
      @opportunity.active_matches do |active_match|
        MatchEvents::DecisionAction.create(match_id: active_match.id, decision_id: active_match.current_decision.id, action: :canceled, contact_id: current_user.contact&.id)
        active_match.poached!
      end
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
      match_route: @opportunity.match_route,
      universe_state: @universe_state
    )
    match.activate!
    redirect_to match_path match
  end

  def set_client
    @client = client_scope.find params[:client_id].to_i
  end

  def set_opportunity
    @opportunity = opportunity_scope.find params[:id].to_i
  end

  def opportunity_scope
    Opportunity.available_for_poaching.joins(sub_program: :program).
      order(Program.arel_table[:name].asc, SubProgram.arel_table[:name].asc, id: :asc)
  end

  def client_scope
    Client.accessible_by_user(current_user)
  end

  def some_clients_viewable!
    client_scope.exists?
  end

  def some_clients_editable!
    Client.editable_by(current_user).exists?
  end
end
