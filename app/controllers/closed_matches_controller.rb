# frozen_string_literal: true

###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ClosedMatchesController < MatchListBaseController
  before_action :require_can_view_all_matches_or_can_view_own_closed_matches!
  before_action :set_available_routes
  before_action :set_current_route
  before_action :set_available_steps
  before_action :set_sort_options

  def index
    # Handle search queries
    handle_search_query

    @match_state = :closed_matches
    @show_vispdat = show_vispdat?
    @matches = match_scope
    @current_step = params[:current_step]
    @current_program = params[:current_program]
    @current_contact_type = params[:current_contact_type]&.to_sym
    @current_filter_contact = if current_user.can_view_all_matches?
      params[:current_filter_contact].to_i if params[:current_filter_contact].present?
    elsif @current_contact_type.present?
      current_user.contact&.id
    end
    @matches = filter_by_step(@current_step, @matches)
    @matches = filter_by_route(@current_route, @matches)
    @matches = filter_by_program(@current_program, @matches)
    @matches = filter_by_contact(@current_filter_contact, @current_contact_type, @matches)
    @search_string = params[:q]
    @matches = search_matches(@search_string, @matches)
    @matches = @matches.joins("CROSS JOIN LATERAL (#{decision_sub_query.to_sql}) last_decision").
      joins(:client).
      order(sort_matches)
    @match_ids = @matches.pluck(:id)
    @column = sort_column
    @direction = sort_direction
    @active_filter = [@current_step, @current_program, @current_contact_type, @current_filter_contact].map(&:presence).any?
    @types = MatchRoutes::Base.match_steps

    @page_size = 25
    @page = params[:page] || 0
    opportunity_ids = @matches.pluck(:opportunity_id, qualified_match_sort_column).
      map(&:first).
      uniq

    @opportunities = opportunity_scope.where(id: opportunity_ids).
      order_as_specified(distinct_on: true, id: opportunity_ids).
      # order("array_position(ARRAY#{opportunity_ids}, opportunities.id)").
      page(@page).per(@page_size)
    @opportunities_array = @opportunities.
      preload(
        :voucher,
        :match_route,
        unit: [:building],
        sub_program: [
          :program,
        ],
        @match_state =>
        [
          :initialized_decisions,
          :decisions,
          :match_route,
          :sub_program,
          :program,
          client: [
            :project_client,
            :active_matches,
          ],
        ],
      ).
      to_a
  end

  def require_can_view_all_matches_or_can_view_own_closed_matches!
    can_view_all_matches? || can_view_own_closed_matches?
  end

  def match_scope
    if can_view_all_matches?
      match_source.
        accessible_by_user(current_user).
        closed.
        joins(:client)
    else
      match_source.
        hsa_involved.
        accessible_by_user(current_user).
        closed.
        joins(:client)
    end
  end

  def set_heading
    @heading = 'Closed Matches'
  end

  # TODO: remove this, there was a duplicate method, leaving as of 11/13/2022
  # until we've confirmed it was unnecessary
  # private def match_scope
  #   match_source.accessible_by_user(current_user).closed
  # end

  private def sort_column
    available_sort = ClientOpportunityMatch.sort_options.map { |m| m[:column] }
    available_sort.include?(params[:sort]) ? params[:sort] : 'last_decision'
  end

  private def sort_direction
    ['asc', 'desc'].include?(params[:direction]) ? params[:direction] : 'desc'
  end

  def handle_search_query
    return unless search_params_present?

    # When someone searches, capture the full context including filters
    # Make sure we capture the current state from the page, not just URL params
    search_params = {
      q: params[:q],
      current_route: @current_route_name,
      current_step: params[:current_step],
      current_program: params[:current_program],
      current_contact_type: params[:current_contact_type],
      current_filter_contact: params[:current_filter_contact],
      sort: params[:sort] || sort_column,
      direction: params[:direction] || sort_direction,
    }.compact

    permitted_params = ClientSearchQuery.permit_params(ActionController::Parameters.new(search_params))
    return unless permitted_params.present?

    @search_query = ClientSearchQuery.find_or_create_by_params(permitted_params, user: current_user)
    return if @search_query.errors.any?

    redirect_to closed_match_search_query_path(@search_query) if request.get?
  rescue ActiveRecord::RecordInvalid
    # Handle validation errors gracefully
  end

  def search_params_present?
    params[:q].present? && params[:q].strip.present?
  end
end
