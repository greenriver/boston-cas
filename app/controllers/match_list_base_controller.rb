class MatchListBaseController < ApplicationController
  
  before_action :authenticate_user!
  before_action :set_heading
  helper_method :sort_column, :sort_direction
  
  def index
    # search
    @matches = if params[:q].present?
      match_scope.text_search(params[:q])
    else
      match_scope
    end

    # sort / paginate
    column = "client_opportunity_matches.#{sort_column}"
    if sort_column == 'calculated_first_homeless_night'
      column = 'clients.calculated_first_homeless_night'
    elsif sort_column == 'client_id'
      column = 'clients.last_name'
    end
    sort = "#{column} #{sort_direction}"

    @matches = match_scope
      .references(:client)
      .includes(:client)
      .order(sort)
      .preload(:client, :opportunity, :decisions)
      .page(params[:page]).per(25)
  end
  
  private
  
    def match_scope
      raise 'abstract method'
    end
    
    def set_heading
      raise 'abstract method'
    end
  
    def sort_column
      match_scope.column_names.include?(params[:sort]) ? params[:sort] : 'calculated_first_homeless_night'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def query_string
      "%#{params[:q]}%"
    end
  
end