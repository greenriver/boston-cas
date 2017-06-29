class ClosedMatchesController < MatchListBaseController
  
  before_action :require_can_view_all_matches_or_can_view_own_closed_matches!
  
  def index
    # search
    if params[:q].present?
      search_scope = match_scope.text_search(params[:q])
      unless current_user.contact.user_can_view_all_clients?
        search_scope = search_scope.where(id: visible_match_ids())
      end
      @matches = search_scope
    else
      @matches = match_scope
    end
    # decision subquery

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
    elsif sort_column == 'last_decision'
      column = "last_decision.updated_at"
    elsif sort_column == 'current_step'
      column = 'last_decision.type'
    end
    sort = "#{column} #{sort_direction}"

    
    if params[:current_step].present? && ClientOpportunityMatch::CLOSED_REASONS.include?(params[:current_step])
      @matches = @matches.public_send(params[:current_step])
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
    @active_filter = @data_source_id.present? || @start_date.present?
  end

  def require_can_view_all_matches_or_can_view_own_closed_matches!
    can_view_all_matches? || can_view_own_closed_matches?
  end
  
  def match_scope
    if can_view_all_matches?
      ClientOpportunityMatch
        .accessible_by_user(current_user)
        .closed
    else
      ClientOpportunityMatch.
        hsa_involved.
        accessible_by_user(current_user).
        closed
    end
  end
  
  def set_heading
    @heading = 'Closed Matches'
  end

  private def sort_column
    available_sort = ClientOpportunityMatch.sort_options.map{|m| m[:column]}
    available_sort.include?(params[:sort]) ? params[:sort] : 'created_at'
  end

  private def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
