###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class ClientsController < ApplicationController
  include ArelHelper
  include Search

  before_action :authenticate_user!
  before_action :require_some_clients_viewable!
  before_action :require_some_clients_editable!, only: [:update, :destroy]
  before_action :set_client, only: [:show, :edit, :update, :destroy, :unavailable]

  helper_method :sort_column, :sort_direction

  # GET /hmis/clients
  def index
    # Handle search queries
    handle_search_query
    return if performed?

    filter_data
  end

  def search
    @search_query = ClientSearchQuery.find(params[:id])
    return handle_invalid_query('Search query not found') if @search_query.nil?

    @search_query.touch

    filter_data

    render :index
  end

  private def filter_data
    @show_vispdat = can_view_vspdats?
    @show_assessment = Client.where.not(assessment_score: 0).exists?
    sort_string = sorter

    @sorted_by = Client.sort_options(show_vispdat: @show_vispdat, show_assessment: @show_assessment).select do |m|
      m[:column] == @column && m[:direction] == @direction
    end.first[:title]

    @search = search_setup(scope: :text_search)
    @query = @search_string || @search_query&.query_params&.[](:q) # for the search form
    @clients = if @search_string.present?
      @search
    else
      client_scope
    end
    # Filter
    if params[:veteran].present?
      if params[:veteran] == '1'
        @clients = @clients.veteran
      elsif params[:veteran] == '0'
        @clients = @clients.non_veteran
      end
    end
    if params[:availability].present?
      available_scope = Client.possible_availability_states.keys.detect { |m| m == params[:availability].to_sym }
      available_scope ||= :all
      @clients = @clients.public_send(available_scope)
    end
    # paginate
    @page = params[:page].presence || 1
    @clients = @clients.reorder(sort_string).page(@page.to_i).per(25)

    client_ids = @clients.map(&:id)

    @matches = ClientOpportunityMatch.
      group(:client_id).
      where(client_id: client_ids).
      count

    @active_filter = params[:availability].present? || params[:veteran].present?
    @available_clients = @clients.available
    @unavailable_clients = @clients.unavailable
  end

  private def search_params
    # Setup some instance variables for sorting
    sorter
    {
      q: params[:q] || @search_query&.query_params&.[](:q),
      availability: params[:availability],
      veteran: params[:veteran],
      sort: @column,
      direction: @direction,
    }.compact
  end

  def sanitized_search_params
    search_params.to_h.symbolize_keys.except(:q)
  end
  helper_method :sanitized_search_params

  private def search_scope
    client_scope
  end

  # GET /clients/1
  def show
    @column_data = Client.prioritized_columns_data
    @client_notes = @client.client_notes
    @client_note = ClientNote.new
    @neighborhood_interests = Neighborhood.where(id: @client.neighborhood_interests).order(:name).pluck(:name)
    @client.unavailable_as_candidate_fors.preload(:route, match: :match_route)
    files = Warehouse::File.for_client(@client.remote_id).
      joins(taggings: :tag).
      preload(taggings: :tag)
    @files = files.map do |file|
      file.taggings.map do |tagging|
        [tagging.tag.name, file]
      end
    end.flatten(1).uniq
  end

  def update
    if @client.update(client_params)
      # If we have a future prevent_matching_until date, remove the client from
      # any current matches
      prevent_matching_until = params[:client].try(:[], :prevent_matching_until)
      should_prevent_matching = prevent_matching_until.present? && prevent_matching_until.to_date > Date.current

      @client.unavailable(permanent: false, contact_id: current_contact.id, cancel_all: true, expires_at: prevent_matching_until.to_date, user: current_user) if should_prevent_matching

      if request.xhr?
        head :ok
      else
        redirect_to client_path(@client), notice: 'Client updated'
      end
    else
      render :show, { flash: { error: 'Unable update client.' } }
    end
  end

  # PATCH /clients/:id/unavailable
  # Find any matches where the client is the active client
  # Remove the client from the match
  # Activate the next client
  # Remove the client from any other proposed matches
  # Mark the Client as available = false
  def unavailable
    @client.unavailable(permanent: true, user: current_user)
    redirect_to action: :show
  end

  private

  def filter_terms
    [:availability, :veteran]
  end
  helper_method :filter_terms

  def sorter
    @column = params[:sort]
    @direction = params[:direction]

    if @column.blank?
      @column = 'days_homeless_in_last_three_years'
      @direction = 'desc'
      sort_string = "#{@column} #{@direction}"
    else
      sort_string = Client.sort_options.select do |m|
        m[:column] == @column && m[:direction] == @direction
      end.first[:order]
    end

    sort_string += ' NULLS LAST' if ApplicationRecord.connection.adapter_name == 'PostgreSQL'
    sort_string
  end

  def client_scope
    Client.accessible_by_user(current_user)
  end

  def set_client
    @client = client_scope.find(params[:id])
  end

  def client_params
    params.require(:client).
      permit(
        :source,
        :release_of_information,
        :dmh_eligible,
        :va_eligible,
        :hues_eligible,
        :confidential,
      )
  end

  def sort_column
    Client.column_names.include?(params[:sort]) ? params[:sort] : 'calculated_first_homeless_night'
  end

  def sort_direction
    ['asc', 'desc'].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def query_string
    "%#{@query}%"
  end

  def require_some_clients_viewable!
    not_authorized! unless client_scope.exists?
  end

  def require_some_clients_editable!
    not_authorized! unless Client.editable_by(current_user).exists?
  end

  private def handle_search_query
    return unless params[:q]&.strip.present?

    # When someone searches, capture the full context including filters
    # Make sure we capture the current state from the page, not just URL params
    permitted_params = ClientSearchQuery.permit_params(ActionController::Parameters.new(search_params))
    return unless permitted_params.present?

    @search_query = ClientSearchQuery.find_or_create_by_params(permitted_params, user: current_user)
    return if @search_query.errors.any?

    redirect_to search_path if request.get?
  rescue ActiveRecord::RecordInvalid
    # Handle validation errors gracefully
  end
end
