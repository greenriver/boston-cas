class ActiveMatchesController < MatchListBaseController
  helper_method :sort_column, :sort_direction
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

    @available_steps = MatchDecisions::Base.filter_options.map do |value|
      if MatchDecisions::Base.available_sub_types_for_search.include?(value)
        [value.constantize.new.step_name, value]
      else
        [value.capitalize, value]
      end
    end
    @available_routes = MatchRoutes::Base.filterable_routes
    @sort_options = ClientOpportunityMatch.sort_options

    md = MatchDecisions::Base.where('match_id = client_opportunity_matches.id').
      where.not(status: nil).
      order(created_at: :desc).limit(1)

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
    @show_vispdat = show_vispdat?

    @current_step = params[:current_step]
    if @current_step.present? && MatchDecisions::Base.filter_options.include?(@current_step)
      if MatchDecisions::Base.stalled_match_filter_options.include?(@current_step)
        # determine delinquent progress updates
        if @current_step == 'Stalled Matches - awaiting response'
          # We only want matches where no-one has responded to the most recent request
          # This will still show matches where no request has been made, if the match has stalled.
          delinquent_match_ids = ClientOpportunityMatch.delinquent_match_ids
          @matches = @matches.stalled.where(id: delinquent_match_ids) 
        elsif @current_step == 'Stalled Matches - with response'
          response_provided_ids = ClientOpportunityMatch.at_least_one_response_in_current_iteration_ids
          @matches = @matches.stalled.where(id: response_provided_ids)
        end
      else
        @matches = @matches.where(last_decision: {type: @current_step})
      end
    end

    @current_route = params[:current_route]
    if @current_route.present? && MatchRoutes::Base.filterable_routes.values.include?(@current_route)
      @matches = @matches.joins(:match_route).where(match_routes: {type: @current_route})
    end

    @matches = @matches.references(:client).
      includes(:client).
      joins("CROSS JOIN LATERAL (#{md.to_sql}) last_decision").
      order(sort).
      preload(:client, :opportunity, :decisions).
      page(params[:page]).per(25)

    @column = sort_column
    @direction = sort_direction
    @active_filter = @current_step.present? || @current_route.present?
    @types = MatchRoutes::Base.match_steps
  end
  
  
  
  private def match_scope
    ClientOpportunityMatch.
      accessible_by_user(current_user).
      active.
      joins(:client)
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

end
