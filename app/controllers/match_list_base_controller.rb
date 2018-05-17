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
    elsif sort_column == 'vispdat_score'
      column = 'clients.vispdat_score'
    elsif sort_column == 'vispdat_priority_score'
      column = 'clients.vispdat_priority_score'
    end
    sort = "#{column} #{sort_direction}"
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      sort = sort + ' NULLS LAST'
    end
    
    @matches = @matches.
      references(:client).
      includes(:client).
      order(sort).
      preload(:client, :opportunity, :decisions).
      page(params[:page]).per(25)
    @show_vispdat = show_vispdat?
  end
  
  protected
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

    def show_vispdat?
      can_view_vspdats?
    end

    def default_sort_direction
      'desc'
    end

    def default_sort_column
      'days_homeless_in_last_three_years'
    end
  
    def sort_column
      (match_scope.column_names + ['last_decision', 'current_step', 'days_homeless', 'days_homeless_in_last_three_years', 'vispdat_score']).include?(params[:sort]) ? params[:sort] : default_sort_column
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : default_sort_direction
    end

    def query_string
      "%#{params[:q]}%"
    end
  
end