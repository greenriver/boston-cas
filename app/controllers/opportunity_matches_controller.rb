###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
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
    @actives = @opportunity.active_matches.map(&:client).compact
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
    @match_ids = @matches.pluck(:id)
  end

  def create
    client_ids_to_activate = params[:checkboxes].select { |_key, value| value == '1' }.keys.map(&:to_i)
    client_ids_to_activate.each do |client_id|
      match = ClientOpportunityMatch.where(client_id: client_id, opportunity_id: @opportunity, closed: false).
        first_or_create(create_match_attributes(client_id))
      match.activate!(touch_referral_event: @opportunity.match_route.auto_initialize_event?)
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

    match.activate!(touch_referral_event: @opportunity.match_route.auto_initialize_event?)
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
      universe_state: universe_state,
    }
  end

  def prioritized_column_data
    @prioritized_column_data ||= Client.prioritized_columns_data
  end

  def prioritized_column_labels
    [].tap do |result|
      @opportunity.match_route.prioritized_client_columns.map(&:to_sym).each do |column|
        column_data = prioritized_column_data[column]
        next if column_data.blank?
        next if column_data[:display_check].present? && send(column_data[:display_check]) == false

        title = column_data[:title]
        title = column_data[:alt_title] if column_data[:alt_title].present?
        result << title
      end
    end
  end
  helper_method :prioritized_column_labels

  def prioritized_column_values(client)
    [].tap do |result|
      @opportunity.match_route.prioritized_client_columns.map(&:to_sym).each do |column|
        column_data = prioritized_column_data[column]
        next if column_data.blank?
        next if column_data[:display_check].present? && send(column_data[:display_check]) == false

        result << client.send(column)
      end
    end
  end
  helper_method :prioritized_column_values

  def priority_labels
    supporting_data_columns = @opportunity.match_route.match_prioritization.supporting_data_columns
    return supporting_data_columns.keys if supporting_data_columns.present?

    [@opportunity.match_route.match_prioritization.title]
  end
  helper_method :priority_labels

  def priority_values(client)
    supporting_data_columns = @opportunity.match_route.match_prioritization.supporting_data_columns
    return supporting_data_columns.values.map { |fn| fn.call(client) } if supporting_data_columns.present?

    fn = @opportunity.match_route.match_prioritization.client_prioritization_summary_method
    value = if client.class.column_names.include?(fn.to_s)
      client.send(fn)
    else
      client.send(fn, match_route: @opportunity.match_route)
    end

    [value]
  end
  helper_method :priority_values

  def match_routes(client)
    counts = client.client_opportunity_matches.active.open.
      joins(:program, :match_route).
      where.not(opportunity: @opportunity).
      group(:type).
      count
    counts.map do |key, value|
      [key.constantize.new.title, value]
    end
  end
  helper_method :match_routes

  def show_confidential_names?
    @show_confidential_names
  end
  helper_method :show_confidential_names?

  private

  def require_access_to_opportunity!
    not_authorized! unless @opportunity.show_alternate_clients_to?(current_user) &&
        @opportunity.visible_by?(current_user)
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
    @heading = 'Eligible Clients for Vacancy'
  end
end
