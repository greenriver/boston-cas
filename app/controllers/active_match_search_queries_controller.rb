###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class ActiveMatchSearchQueriesController < ActiveMatchesController
  def show
    @search_query = ClientSearchQuery.find(params[:id])

    # If someone submits an empty search, redirect to main index with preserved filters
    if params[:q] && params[:q].strip.blank?
      # Use saved search query parameters as the baseline, excluding the empty search term
      preserved_params = @search_query.query_params.except('q').merge(
        params.permit(:current_route, :current_step, :current_program, :current_contact_type, :current_filter_contact, :sort, :direction).compact,
      )
      redirect_to active_matches_path(preserved_params)
      return
    end

    # If there's a new search query in params, handle it
    if search_params_present? && search_params_different?
      handle_search_query
      return if performed? # Stop if we redirected
    end

    # Use the saved search query parameters
    @search_query.query_params.each do |key, value|
      params[key] = value
    end

    # Trigger the before_action callbacks manually since we're overriding params
    set_available_routes
    set_current_route
    set_sort_options

    # Only set available steps if current route is valid
    set_available_steps if @current_route.present?

    # Call parent logic
    @match_state = :active_matches
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

    # Ensure sorting parameters are properly set from saved query
    @column = params[:sort] || sort_column
    @direction = params[:direction] || sort_direction
    @active_filter = [@current_step, @current_program, @current_contact_type, @current_filter_contact].map(&:presence).any?
    @types = MatchRoutes::Base.match_steps

    @page_size = 25
    @page = params[:page] || 0
    opportunity_ids = @matches.pluck(:opportunity_id, qualified_match_sort_column).
      map(&:first).
      uniq

    @opportunities = opportunity_scope.where(id: opportunity_ids)
    @opportunities = @opportunities.order_as_specified(distinct_on: true, id: opportunity_ids) unless opportunity_ids.empty?
    @opportunities = @opportunities.page(@page).per(@page_size)
    @opportunities_array = @opportunities.
      preload(
        :voucher,
        :match_route,
        unit: [:building],
        sub_program: [:program],
        active_matches: [
          :contacts,
          :dnd_staff_contacts,
          :housing_subsidy_admin_contacts,
          :client_contacts,
          :shelter_agency_contacts,
          :ssp_contacts,
          :hsp_contacts,
          :do_contacts,
          :hsa_or_shelter_agency_contacts,
        ],
        closed_matches: [
          :contacts,
          :dnd_staff_contacts,
          :housing_subsidy_admin_contacts,
          :client_contacts,
          :shelter_agency_contacts,
          :ssp_contacts,
          :hsp_contacts,
          :do_contacts,
          :hsa_or_shelter_agency_contacts,
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

    render template: 'active_matches/index'
  end

  private

  def filter_params
    # Override to make the Clear button go to the active_matches index
    super.merge(controller: 'active_matches', action: 'index')
  end
  helper_method :filter_params

  def sort_column
    # Use saved search query sort if available, otherwise fall back to parent
    params[:sort] || super
  end
  helper_method :sort_column

  def sort_direction
    # Use saved search query direction if available, otherwise fall back to parent
    params[:direction] || super
  end
  helper_method :sort_direction

  def search_params_different?
    # Only consider it different if there's a new search term
    params[:q].present? && params[:q].strip.present? && params[:q] != @search_query.query_params[:q]
  end
end
