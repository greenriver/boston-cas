###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class UnavailableClientSearchQueriesController < UnavailableClientsController
  skip_before_action :set_client

  def show
    @search_query = ClientSearchQuery.find(params[:id])

    # If there's a new search query in params, handle it
    if params[:search_form].present? && params[:search_form][:q].present? && params[:search_form][:q] != @search_query.query_params[:q]
      handle_search_query
      return if performed? # Stop if we redirected
    end

    @show_vispdat = can_view_vspdats?
    @show_assessment = Client.where.not(assessment_score: 0).exists?
    sort_string = sorter

    @sorted_by = Client.sort_options(show_vispdat: @show_vispdat, show_assessment: @show_assessment).select do |m|
      m[:column] == @column && m[:direction] == @direction
    end.first[:title]

    # Use the saved search query parameters
    params[:search_form] = @search_query.query_params
    @search = search_setup(scope: :text_search)

    # Start with unavailable clients only
    @clients = if @search_string.present?
      @search.unavailable
    else
      client_scope.unavailable
    end

    # Filter
    if params[:veteran].present?
      if params[:veteran] == '1'
        @clients = @clients.veteran
      elsif params[:veteran] == '0'
        @clients = @clients.non_veteran
      end
    end

    # For unavailable clients, we still check the availability filter but it mainly affects the display
    if params[:availability].present?
      available_scope = Client.possible_availability_states.keys.detect { |m| m == params[:availability].to_sym }
      available_scope ||= :all
      @clients = @clients.public_send(available_scope) if available_scope != :unavailable
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

    render template: 'unavailable_clients/index'
  end
end
