class ClosedMatchesController < MatchListBaseController
  before_action :require_can_view_all_matches_or_can_view_own_closed_matches!

  def index
    # search
    if params[:q].present?
      search_scope = match_scope.text_search(params[:q])
      unless current_user.can_view_all_clients?
        search_scope = search_scope.where(id: visible_match_ids())
      end
      @matches = search_scope
    else
      @matches = match_scope
    end
    # decision subquery

    @available_routes = MatchRoutes::Base.filterable_routes

    md = MatchDecisions::Base.where(
      'match_id = client_opportunity_matches.id'
    ).where.not(status: nil).order(created_at: :desc).limit(1)

    # sort / paginate
    column = "client_opportunity_matches.#{sort_column}"
    if sort_column == 'calculated_first_homeless_night'
      column = 'clients.calculated_first_homeless_night'
    elsif sort_column == 'last_name'
      column = 'clients.last_name'
    elsif sort_column == 'first_name'
      column = 'clients.first_name'
    elsif sort_column == 'days_homeless'
      column = 'clients.days_homeless'
    elsif sort_column == 'days_homeless_in_last_three_years'
      column = 'clients.days_homeless_in_last_three_years'
    elsif sort_column == 'last_decision'
      column = "last_decision.updated_at"
    elsif sort_column == 'current_step'
      column = 'last_decision.type'
    elsif sort_column == 'vispdat_score'
      column = 'clients.vispdat_score'
    elsif sort_column == 'vispdat_priority_score'
      column = 'clients.vispdat_priority_score'
    end
    sort = "#{column} #{sort_direction}"
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      sort = sort + ' NULLS LAST'
    end
    @show_vispdat = show_vispdat?

    @current_step = params[:current_step]
    if @current_step.present? && ClientOpportunityMatch::CLOSED_REASONS.include?(@current_step)
      @matches = @matches.public_send(@current_step)
    end

    @current_route = params[:current_route]
    if @current_route.present? && MatchRoutes::Base.filterable_routes.values.include?(@current_route)
      @matches = @matches.joins(:match_route).where(match_routes: {type: @current_route})
    end

    @matches = @matches
      .references(:client)
      .includes(:client)
      .joins("CROSS JOIN LATERAL (#{md.to_sql}) last_decision")
      .order(sort)
      .preload(:client, :opportunity, :decisions)
      .page(params[:page]).per(25)

    @column = sort_column
    @direction = sort_direction
    @active_filter = @current_step.present? || @current_route.present?
    @types = MatchRoutes::Base.match_steps
  end

  def require_can_view_all_matches_or_can_view_own_closed_matches!
    can_view_all_matches? || can_view_own_closed_matches?
  end

  def match_scope
    if can_view_all_matches?
      ClientOpportunityMatch.
        accessible_by_user(current_user).
        closed.
        joins(:client)
    else
      ClientOpportunityMatch.
        hsa_involved.
        accessible_by_user(current_user).
        closed.
        joins(:client)
    end
  end

  def set_heading
    @heading = 'Closed Matches'
  end

  private def sort_column
    available_sort = ClientOpportunityMatch.sort_options.map{|m| m[:column]}
    available_sort.include?(params[:sort]) ? params[:sort] : 'last_decision'
  end

  private def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
