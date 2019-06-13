###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ClientOpportunityMatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match, only: [:show]
  before_action :require_can_view_all_matches!
  
  helper_method :sort_column, :sort_direction

  def index
    # search
    @matches = if params[:q].present?
      match_scope.text_search(params[:q])
    else
      match_scope
    end

    # client filter
    if params[:client_id].present? && (@client = Client.find(params[:client_id].to_i))
      @matches = @matches.where(client_id: @client.id)
    end

    # opportunity filter
    if params[:opportunity_id].present? && (@opportunity = Opportunity.find(params[:opportunity_id].to_i))
      @matches = @matches.where(opportunity_id: @opportunity.id) 
    end

    # sort / paginate
    @matches = @matches
      .order(sort_column => sort_direction)
      .preload(:client, :opportunity, :notifications)
      .page(params[:page]).per(25)
  end

  def show
    @client = @match.client
    @opportunity = @match.opportunity
    @decisions = @match.initialized_decisions
  end

  # temp route to create a random match to ease development
  def create
    client = Client.order('RANDOM()').first
    opportunity = Opportunity.where(available: true).order('RANDOM()').first
    
    match = ClientOpportunityMatch.create!(
      score: Faker::Number.between(25, 100),
      client: client,
      opportunity: opportunity,
      proposed_at: Date.today
    )
    match.add_default_contacts!
    match.match_recommendation_dnd_staff_decision.initialize_decision!
    flash[:notice] = 'Random Match created'
    redirect_to root_path
  end

  private

  def match_scope
    ClientOpportunityMatch
  end

  def set_match
    @match = match_scope.find(params[:id])
  end
  
  def authorization_record
    @match
  end

  def sort_column
    match_scope.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def query_string
    "%#{params[:q]}%"
  end

end