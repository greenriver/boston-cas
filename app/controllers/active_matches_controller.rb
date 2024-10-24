###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ActiveMatchesController < MatchListBaseController
  before_action :set_available_routes
  before_action :set_current_route
  before_action :set_available_steps
  before_action :set_sort_options

  helper_method :sort_column, :sort_direction

  def index
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
    @column = sort_column
    @direction = sort_direction
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
  end

  private def match_scope
    match_source.accessible_by_user(current_user).active.preload(:decisions)
  end

  private def set_heading
    @heading = 'Matches in Progress'
  end

  def sort_column
    available_sort = ClientOpportunityMatch.sort_options.map { |m| m[:column] }
    @sort_column ||= available_sort.include?(params[:sort]) ? params[:sort] : 'last_decision'
  end

  def sort_direction
    ['asc', 'desc'].include?(params[:direction]) ? params[:direction] : 'desc'
  end
end
