###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
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
    @matches = filter_by_step(@current_step, @matches)
    @matches = filter_by_route(@current_route, @matches)
    @matches = filter_by_program(@current_program, @matches)
    @search_string = params[:q]
    @matches = search_matches(@search_string, @matches)
    @matches = @matches.joins("CROSS JOIN LATERAL (#{decision_sub_query.to_sql}) last_decision").
      joins(:client).
      order(sort_matches)
    @column = sort_column
    @direction = sort_direction
    @active_filter = @current_step.present? || @current_program.present?
    @types = MatchRoutes::Base.match_steps

    @page_size = 25
    @page = params[:page] || 0
    opportunity_ids = @matches.pluck(:opportunity_id, qualified_match_sort_column).
      map(&:first).
      uniq

    @opportunities = opportunity_scope.where(id: opportunity_ids)
    @opportunities = @opportunities.order_as_specified(distinct_on: true, id: opportunity_ids) unless opportunity_ids.empty?
    @opportunities = @opportunities.
      preload(
        :voucher,
        :match_route,
        sub_program: [:program],
        @match_state =>
        [
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
      page(@page).per(@page_size)
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
