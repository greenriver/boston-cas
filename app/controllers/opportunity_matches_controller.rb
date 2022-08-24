###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class OpportunityMatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_access_to_opportunity!
  before_action :require_can_activate_matches!, only: [:create, :update]
  before_action :set_heading
  before_action :set_show_confidential_names

  prepend_before_action :find_opportunity!

  def index
    clients_for_route = Client.available_for_matching(@opportunity.match_route)
    @actives = @opportunity.active_matches.map { |match| match.client }.compact
    @availables = @opportunity.matching_clients(clients_for_route)
    @matches = (@actives + @availables).uniq
    @sub_program = @opportunity.sub_program
    @program = @sub_program.program
  end

  def closed
    @matches = @opportunity.closed_matches
    @match_state = :closed_matches
    @opportunities = @opportunity.class.where(id: @opportunity.id)
    @sub_program = @opportunity.sub_program
    @program = @sub_program.program
  end

  def create
    client_ids_to_activate = params[:checkboxes].reject { | key, value | value != "1" }.keys.map(&:to_i)
    client_ids_to_activate.each do | client_id |
      match = ClientOpportunityMatch.where(client_id: client_id, opportunity_id: @opportunity, closed: false).
          first_or_create(create_match_attributes(client_id))
      match.activate!
    end
    redirect_to opportunity_matches_path(@opportunity)
  end

  def update
    client_id =  params[:id].to_i

    unless @opportunity.match_route.allow_multiple_active_matches
      @opportunity.active_matches.each do |active_match|
        MatchEvents::DecisionAction.create(match_id: active_match.id, decision_id: active_match.current_decision.id, action: :canceled, contact_id: current_user.contact&.id)
        active_match.poached!
      end
    end

    match = ClientOpportunityMatch.create(create_match_attributes(client_id))

    match.activate!
    redirect_to match_path match
  end

  def create_match_attributes(client_id)
    client = Client.find(client_id)

    universe_state = {
      requirements: @opportunity.requirements_for_archive,
      services: @opportunity.services_for_archive,
      opportunity: @opportunity.opportunity_details.opportunity_for_archive,
      client: client.prepare_for_archive,
    }

    return {
      opportunity: @opportunity,
      client: client,
      match_route: @opportunity.match_route,
      universe_state: universe_state
    }
  end

  def priority_label
    @opportunity.match_route.match_prioritization.title
  end
  helper_method :priority_label

  def supporting_data_columns
    @opportunity.match_route.match_prioritization.supporting_data_columns
  end
  helper_method :supporting_data_columns

  def priority_value(client)
    meth = @opportunity.match_route.match_prioritization.client_prioritization_value_method
    if client.class.column_names.include?(meth.to_s)
      client.send(meth)
    else
      client.send(meth, match_route: @opportunity.match_route)
    end
  end
  helper_method :priority_value

  def match_routes(client)
    counts = client.client_opportunity_matches.active.open.
        joins(:program, :match_route).
        where.not(opportunity: @opportunity).
        group(:type).
        count
    counts.map do | key, value |
      [ key.constantize.new.title, value ]
    end
  end
  helper_method :match_routes

  def show_confidential_names?
    @show_confidential_names
  end
  helper_method :show_confidential_names?

  private

    def require_access_to_opportunity!
      not_authorized! unless (@opportunity.show_alternate_clients_to?(current_user) &&
          @opportunity.visible_by?(current_user))
    end

    def can_activate_matches?
      (current_user.can_edit_all_clients? ||
          @opportunity.editable_by?(current_user)) &&
          ! @opportunity.successful_match
    end
    helper_method :can_activate_matches?

    def require_can_activate_matches!
      not_authorized! unless can_activate_matches?
    end

    def set_show_confidential_names
      @show_confidential_names = can_view_client_confidentiality? && params[:confidential_override].present?
    end

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
