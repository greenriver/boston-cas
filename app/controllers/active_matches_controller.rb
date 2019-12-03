###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ActiveMatchesController < MatchListBaseController
  helper_method :sort_column, :sort_direction
  before_action :set_available_steps, :set_available_routes, :set_sort_options

  def index
    @match_state = :active_matches
    @matches = match_scope
    @show_vispdat = show_vispdat?
    @current_step = params[:current_step]
    @matches = filter_by_step(@current_step, @matches)
    @current_route = params[:current_route]
    @matches = filter_by_route(@current_route, @matches)
    @search_string = params[:q]
    @matches = search_matches(@search_string, @matches)
    @matches = @matches.joins("CROSS JOIN LATERAL (#{decision_sub_query.to_sql}) last_decision").
      joins(:client).
      order(sort_matches())
    @column = sort_column
    @direction = sort_direction
    @active_filter = @current_step.present? || @current_route.present?
    @types = MatchRoutes::Base.match_steps

    @page_size = 25
    @page = params[:page] || 0
    opportunity_ids = @matches.pluck(:opportunity_id, qualified_match_sort_column).
      map(&:first).
      uniq

    # NOTE: Ordering may need to be adjusted based on postgres version https://stackoverflow.com/a/29598910
    @opportunities = opportunity_scope.where(id: opportunity_ids).
      order_as_specified(distinct_on: true, id: opportunity_ids).
      # order("array_position(ARRAY#{opportunity_ids}, opportunities.id)").
      preload(
        :voucher,
        :match_route,
        sub_program: [:program],
        active_matches:
        [
          :decisions,
          :match_route,
          :sub_program,
          :program,
          client: [
            :project_client,
            :active_matches,
          ],
        ]
      ).
      page(@page).per(@page_size)

    # @opportunities = search_opportunities(opportunity_scope).
    #   joins(Arel.sql("CROSS JOIN LATERAL (#{decision_sub_query.to_sql}) last_decision"))
    # @opportunities = @opportunities.distinct.
    #   order(sort_opportunities()).
      # preload(
      #   active_matches:
      #   [
      #     :decisions,
      #     :match_route,
      #     :sub_program,
      #     :program,
      #     client: [
      #       :project_client,
      #       :active_matches,
      #     ],
      #   ]
      # ).
    #   page(params[:page]).per(25)

  end

  private def decision_sub_query
    MatchDecisions::Base.where('match_id = client_opportunity_matches.id').
      where.not(status: nil).
      order(created_at: :desc).limit(1)
  end

  private def set_available_steps
    @available_steps ||= MatchDecisions::Base.filter_options.map do |value|
      if MatchDecisions::Base.available_sub_types_for_search.include?(value)
        option = [
          value.constantize.new.step_name,
          value,
        ]
        if MatchRoutes::Base.more_than_one?
          MatchRoutes::Base.all_routes.each do |route|
            next unless route.available_sub_types_for_search.include?(value)
            title = "#{value.constantize.new.step_name} on #{route.new.title}"
            option = [
              title,
              value
            ]
          end
        end
        option
      else # Handle stalled situation that doesn't match a decision name
        [
          value.capitalize,
          value
        ]
      end
    end

  end

  private def set_available_routes
    @available_routes ||= MatchRoutes::Base.filterable_routes
  end

  private def set_sort_options
    @sort_options ||= ClientOpportunityMatch.sort_options
  end

  private def opportunity_source
    Opportunity
  end

  private def opportunity_scope
    # o_t = Opportunity.arel_table
    # # Need to include this for sorting
    # ld_t = MatchDecisions::Base.arel_table.alias('last_decision')
    # opportunity_source.joins(client_opportunity_matches: [:client, :match_route]).
    #   select(o_t[:id], o_t[:voucher_id], ld_t[:updated_at]).
    #   where(id: match_source.accessible_by_user(current_user).active.select(:opportunity_id))
    opportunity_source.joins(client_opportunity_matches: [:client, :match_route]).
      merge(match_source.accessible_by_user(current_user).active)
  end

  private def match_source
    ClientOpportunityMatch
  end

  private def match_scope
    match_source.accessible_by_user(current_user).active
  end

  private def set_heading
    @heading = 'Matches in Progress'
  end

  def sort_column
    available_sort = ClientOpportunityMatch.sort_options.map{|m| m[:column]}
    @sort_column ||= available_sort.include?(params[:sort]) ? params[:sort] : 'last_decision'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  private def filter_by_step step, scope
    return scope unless step.present? && MatchDecisions::Base.filter_options.include?(step)
    if MatchDecisions::Base.stalled_match_filter_options.include?(step)
      # determine delinquent progress updates
      if step == 'Stalled Matches - awaiting response'
        scope = scope.stalled_notifications_sent
      end
    else
      scope = scope.where(last_decision: {type: step}).select(:opportunity_id)
    end
    scope
  end

  private def filter_by_route route, scope
    return scope unless route.present? && MatchRoutes::Base.filterable_routes.values.include?(route)
    match_source.joins(:match_route).
      where(match_routes: {type: route})
  end

end
