class ActiveMatchesController < MatchListBaseController

  def index
    # search
    @matches = if params[:q].present?
      match_scope.text_search(params[:q])
    else
      match_scope
    end
    # decision subquery

    md = MatchDecisions::Base.where(
      'match_id = client_opportunity_matches.id'
    ).where.not(status: nil).order(created_at: :desc).limit(1)

    # sort / paginate
    column = "client_opportunity_matches.#{sort_column}"
    if sort_column == 'calculated_first_homeless_night'
      column = 'clients.calculated_first_homeless_night'
    elsif sort_column == 'client_id'
      column = 'clients.last_name'
    elsif sort_column == 'last_decision'
      column = "last_decision.updated_at"
    elsif sort_column == 'current_step'
      column = 'last_decision.type'
    end
    sort = "#{column} #{sort_direction}"
    @matches = @matches
      .references(:client)
      .includes(:client)
      .joins("CROSS JOIN LATERAL (#{md.to_sql}) last_decision")
      .order(sort)
      .preload(:client, :opportunity, :decisions)
      .page(params[:page]).per(25)
  end
  
  private
  
    def match_scope
      ClientOpportunityMatch
        .accessible_by_user(current_user)
        .active
    end
    
    def set_heading
      @heading = 'Matches in Progress'
    end

end