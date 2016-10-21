class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_dnd_staff!

  before_action :set_client, only: [:show, :edit, :update, :destroy, :merge, :split, :unavailable]

  helper_method :sort_column, :sort_direction

  # GET /hmis/clients
  def index
    # search
    @clients = if params[:q].present?
      client_scope.text_search(params[:q])
    else
      client_scope
    end

    # sort / paginate
    @clients = @clients
      .order(sort_column => sort_direction)
      .page(params[:page].to_i).per(25)

    @matches = ClientOpportunityMatch
              .group(:client_id)
              .where(client_id: @clients.map(&:id))
              .count
  end

  # GET /clients/1
  def show
    @dupes = find_potential_dupes
    @splits = find_potential_splits
  end

  def update
    if @client.update(client_params)
      # If we have a future prevent_matching_until date, remove the client from 
      # any current matches
      if @client.prevent_matching_until.present? && @client.prevent_matching_until > Date.today
        active_match = @client.client_opportunity_matches.active.first
        Client.transaction do 
          if active_match.present?
            opportunity = active_match.opportunity
            active_match.delete
            opportunity.update(available_candidate: true)
            Matching::RunEngineJob.perform_later
          end
          if @client.client_opportunity_matches.any?
            @client.client_opportunity_matches.each do |opp|
              opp.delete
            end
          end
          # This will re-queue the client once the date is passed
          @client.update(available_candidate: true)
        end
      end
      redirect_to client_path(@client), notice: "Client updated"
    else
      render :show, {flash: {error: 'Unable update client.'}}
    end
  end

  # PATCH /clients/:id/split
  # Sets the merged_into field on the specified client equal to null (un-merging a previous merge)
  def split
    c = client_scope.find(client_params[:source])
    if c.update_attributes(merged_into: nil)
      redirect_to client_path(@client), notice: "Client <strong>#{c.full_name}</strong> was split from #{@client.full_name}."
    else
      render :edit, {flash: {error: 'Unable to split <strong>#{c.full_name}</strong> from client <strong>#{@client.full_name}</strong>.'}}
    end
  end

  # PATCH /clients/:id/unavailable
  # Find any matches where the client is the active client
  # Remove the client from the match
  # Activate the next client
  # Remove the client from any other matches
  # Mark the Client as available = false
  def unavailable
    active_match = @client.client_opportunity_matches.active.first
    Client.transaction do 
      if active_match.present?
        opportunity = active_match.opportunity
        active_match.delete
        opportunity.update(available_candidate: true)
        Matching::RunEngineJob.perform_later
      end
      if @client.client_opportunity_matches.any?
        @client.client_opportunity_matches.each do |opp|
          opp.delete
        end
      end
      @client.update(available: false)
    end
    redirect_to action: :show
  end

  private

  def client_scope
    Client.accessible_by_user(current_user)
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_client
    @client = client_scope.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def client_params
    params.require(:client).
      permit(:source, :release_of_information, :prevent_matching_until)
  end

  # propose duplicate ids for a given client
  def find_potential_dupes
    # only bother showing close matches (currently >= 1)
    score_total_threshold = 1
    potential_dupes = {}
    p_dupes = []
    @strings_to_compare = [:first_name, :middle_name, :last_name, :ssn, :date_of_birth]
    @exacts_to_compare = [:gender, :race, :ethnicity, :veteran_status]

    calculate_scores()
    potential_dupes = add_string_scores(potential_dupes)
    potential_dupes = add_exacts_scores(potential_dupes)

    # get rid of the id we were prevously using for identifying mutlti-matches
    potential_dupes.each do |id, c|
      if c[:score] >= 1
        p_dupes << c
      end
    end
    p_dupes.sort_by {|h| h[:score]}.reverse
  end

  # clients previously merged into this client
  def find_potential_splits
    Client.where(merged_into: @client.id).
      order(last_name: :asc, first_name: :asc)
  end

  def sort_column
    Client.column_names.include?(params[:sort]) ? params[:sort] : 'calculated_first_homeless_night'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def query_string
    "%#{@query}%"
  end

  def calculate_scores
    require 'fuzzy_match'
    @scores = {}
    @strings_to_compare.each do |s|
      compare_strings s
    end
    @exacts_to_compare.each do |s|
      compare_exacts s
    end
    @scores
  end

  def compare_strings s
    search = Client.where.not(id: @client.id, s => nil).
      where(merged_into: nil).
      pluck(s).
      compact.uniq
    # note: All with score comes back in this format:
    # [[similarity.record2.original, bs.dices_coefficient_similar, bs.levenshtein_similar]]
    threshhold = 2.5
    a = FuzzyMatch.new(search, find_all_with_score: true, threshold: threshhold)
    @scores[s] = a.find(@client.first_name)
  end

  def compare_exacts s
    matches = Client.where.not(id: @client.id, s => nil).
      where(merged_into: nil).
      where(s => @client["#{s}_id"]).
      pluck(:id).
      compact.uniq
    @scores[s] = matches
  end

  def add_string_scores potential_dupes
    @strings_to_compare.each do |s|
      @scores[s].each do |set|
        clients = Client.where(s => set[0]).
          where.not(id: @client.id).
          select(:first_name, :last_name, :id)
        clients.each do |c|
          score = 0
          if potential_dupes[c.id]
            score += potential_dupes[c.id][:score]
          end
          score += set[1] + set[2]
          potential_dupes[c.id] = {id: c.id, first_name: c.first_name, last_name: c.last_name, score: score}
        end
      end
    end
    potential_dupes
  end

  def add_exacts_scores potential_dupes
    # never let the total of these = more than 0.5
    exact_weight = 0.5 / @exacts_to_compare.length
    @exacts_to_compare.each do |s|
      clients = Client.where(id: @scores[s]).
        where.not(id: @client.id).
        select(:first_name, :last_name, :id)
      clients.each do |c|
        score = 0
        if potential_dupes[c.id]
          score += potential_dupes[c.id][:score]
        end
        score += exact_weight
        potential_dupes[c.id] = {id: c.id, first_name: c.first_name, last_name: c.last_name, score: score}
      end
    end
    potential_dupes
  end
end
