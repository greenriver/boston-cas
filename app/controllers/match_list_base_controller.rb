###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class MatchListBaseController < ApplicationController
  before_action :authenticate_user!
  before_action :set_heading
  before_action :set_show_confidential_names
  helper_method :sort_column, :sort_direction

  def index
    # search
    @matches = if params[:q].present?
      match_scope.text_search(params[:q])
    else
      match_scope
    end

    @matches = @matches.
      references(:client).
      includes(:client).
      order(sort_opportunities()).
      preload(:client, :opportunity, :decisions).
      page(params[:page]).per(25)
    @show_vispdat = show_vispdat?
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
    elsif sort_column == 'client_id'
      column = 'clients.last_name'
    end
    sort = "#{column} #{sort_direction}"
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      sort = sort + ' NULLS LAST'
    end
  end

  private def qualified_match_sort_column
    @qualified_match_sort_column ||= if sort_column == 'calculated_first_homeless_night'
      'clients.calculated_first_homeless_night'
    elsif sort_column == 'last_name'
      'clients.last_name'
    elsif sort_column == 'first_name'
      'clients.first_name'
    elsif sort_column == 'last_decision'
      "last_decision.updated_at"
    elsif sort_column == 'current_step'
      'last_decision.type'
    elsif sort_column == 'days_homeless'
      'clients.days_homeless'
    elsif sort_column == 'days_homeless_in_last_three_years'
      'clients.days_homeless_in_last_three_years'
    elsif sort_column == 'vispdat_score'
      'clients.vispdat_score'
    elsif sort_column == 'vispdat_priority_score'
      'clients.vispdat_priority_score'
    elsif sort_column == 'client_id'
      'clients.last_name'
    else
      "client_opportunity_matches.#{sort_column}"
    end
  end

  private def sort_matches
    sort = "#{qualified_match_sort_column} #{sort_direction}"
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      sort = sort + ' NULLS LAST'
    end
  end

  private def search_opportunities scope
    return scope unless params[:q].present?
    search_scope = scope.match_text_search(params[:q])
    unless current_user.can_view_all_clients?
      search_scope = search_scope.joins(:client_oppotunity_match).
        where(id: match_source.where(id: visible_match_ids()).select(:opportunity_id))
    end
    search_scope
  end

  private def search_matches search_string, scope
    return scope unless search_string.present?
    search_scope = scope.text_search(search_string)
    unless current_user.can_view_all_clients?
      search_scope = search_scope.where(id: visible_match_ids())
    end
    search_scope
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

    def show_confidential_names?
      @show_confidential_names
    end
    helper_method :show_confidential_names?

    def set_show_confidential_names
      @show_confidential_names = can_view_client_confidentiality? && params[:confidential_override].present?
    end

    def default_sort_direction
      'desc'
    end

    def default_sort_column
      'days_homeless_in_last_three_years'
    end

    def sort_column
      @sort_column ||= (match_scope.column_names + ['last_decision', 'current_step', 'days_homeless', 'days_homeless_in_last_three_years', 'vispdat_score']).include?(params[:sort]) ? params[:sort] : default_sort_column
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : default_sort_direction
    end

    def query_string
      "%#{params[:q]}%"
    end

    def filter_terms
      [ :current_step, :current_route ]
    end
    helper_method :filter_terms

end