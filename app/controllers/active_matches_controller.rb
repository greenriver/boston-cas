###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ActiveMatchesController < MatchListBaseController
  helper_method :sort_column, :sort_direction
  before_action :set_available_steps, :set_available_routes, :set_sort_options

  def index
    @opportunities = search_opportunities(opportunity_scope)

    @show_vispdat = show_vispdat?

    @current_step = params[:current_step]
    @opportunities = filter_by_step(@current_step, @opportunities)

    @current_route = params[:current_route]
    @opportunities = filter_by_route(@current_route, @opportunities)

    @opportunities = @opportunities.merge(match_source.references(:client)).
      includes(client_opportunity_matches: :client).
      joins(Arel.sql("CROSS JOIN LATERAL (#{decision_sub_query.to_sql}) last_decision")).
      order(sort_opportunities()).
      preload(
        client_opportunity_matches:
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
      page(params[:page]).per(25)

    @column = sort_column
    @direction = sort_direction
    @active_filter = @current_step.present? || @current_route.present?
    @types = MatchRoutes::Base.match_steps
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
    opportunity_source.joins(client_opportunity_matches: [:client, :match_route]).
      merge(match_source.accessible_by_user(current_user).active)
  end

  private def match_source
    ClientOpportunityMatch
  end

  private def set_heading
    @heading = 'Matches in Progress'
  end

  private def sort_column
    available_sort = ClientOpportunityMatch.sort_options.map{|m| m[:column]}
    available_sort.include?(params[:sort]) ? params[:sort] : 'last_decision'
  end

  private def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  private def search_opportunities scope
    return scope unless params[:q].present?
    search_scope = scope.match_text_search(params[:q])
    unless current_user.can_view_all_clients?
      search_scope = search_scope.joins(:client_oppotunity_match).
        merge(match_source.where(id: visible_match_ids()))
    end
    search_scope
  end

  private def sort_opportunities
    # sort / paginate
    column = "client_opportunity_matches.#{sort_column}"
    if sort_column == 'calculated_first_homeless_night'
      column = 'clients.calculated_first_homeless_night'
    elsif sort_column == 'last_name'
      column = 'clients.last_name'
    elsif sort_column == 'first_name'
      column = 'clients.first_name'
    elsif sort_column == 'last_decision'
      column = "last_decision.updated_at"
    elsif sort_column == 'current_step'
      column = 'last_decision.type'
    elsif sort_column == 'days_homeless'
      column = 'clients.days_homeless'
    elsif sort_column == 'days_homeless_in_last_three_years'
      column = 'clients.days_homeless_in_last_three_years'
    elsif sort_column == 'vispdat_score'
      column = 'clients.vispdat_score'
    elsif sort_column == 'vispdat_priority_score'
      column = 'clients.vispdat_priority_score'
    end
    sort = "#{column} #{sort_direction}"
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      sort = sort + ' NULLS LAST'
    end
  end

  private def filter_by_step step, scope
    return scope unless step.present? && MatchDecisions::Base.filter_options.include?(step)
    if MatchDecisions::Base.stalled_match_filter_options.include?(step)
      # determine delinquent progress updates
      if step == 'Stalled Matches - awaiting response'
        scope = scope.merge(match_source.stalled_notifications_sent)
      end
    else
      scope = scope.merge(match_source.where(last_decision: {type: step}))
    end
    scope
  end

  private def filter_by_route route, scope
    return scope unless route.present? && MatchRoutes::Base.filterable_routes.values.include?(route)

    scope.merge(match_source.joins(:match_route).where(match_routes: {type: route}))
  end

end
