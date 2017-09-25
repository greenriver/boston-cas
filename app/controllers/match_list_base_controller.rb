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
    elsif sort_column == 'days_homeless'
      column = 'clients.days_homeless'
    elsif sort_column == 'days_homeless_in_last_three_years'
      column = 'clients.days_homeless_in_last_three_years'
    end
    sort = "#{column} #{sort_direction}"
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      sort = sort + ' NULLS LAST'
    end
    
    @matches = @matches
      .references(:client)
      .includes(:client)
      .order(sort)
      .preload(:client, :opportunity, :decisions)
      .page(params[:page]).per(25)
  end
  
  private
    # This is painful, but we need to prevent leaking of client names
    # via targeted search
    def visible_match_ids
      contact = current_user.contact
      contact.client_opportunity_match_contacts.map(&:match).map do |m| 
        m.id if m.try(:show_client_info_to?, contact) || false
      end.compact
    end

    def match_scope
      raise 'abstract method'
    end
    
    def set_heading
      raise 'abstract method'
    end
  
    def sort_column
      (match_scope.column_names + ['last_decision', 'current_step', 'days_homeless', 'days_homeless_in_last_three_years']).include?(params[:sort]) ? params[:sort] : 'calculated_first_homeless_night'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def query_string
      "%#{params[:q]}%"
    end
  
end