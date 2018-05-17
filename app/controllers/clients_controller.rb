class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_view_all_clients!
  before_action :require_can_edit_all_clients!, only: [:update, :destroy]
  before_action :set_client, only: [:show, :edit, :update, :destroy, :unavailable]

  helper_method :sort_column, :sort_direction

  # GET /hmis/clients
  def index
    @show_vispdat = can_view_vspdats?
    default_sort = 'days_homeless_in_last_three_years desc'
    sort_string = params[:q].try(:[], :s) || default_sort
    (@column, @direction) = sort_string.split(' ')
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      sort_string = sort_string + ' NULLS LAST'
    end
     
    @sorted_by = Client.sort_options(show_vispdat: @show_vispdat).select do |m| 
      m[:column] == @column && m[:direction] == @direction
    end.first[:title]
    @q = client_scope.ransack(params[:q])
    @clients = @q.result(distinct: true)
    # Filter
    if params[:veteran].present?
      if params[:veteran] == '1'
        @clients = @clients.veteran
      elsif params[:veteran] == '0'
        @clients = @clients.non_veteran
      end
    end
    if params[:availability].present?
      available_scope = Client.possible_availability_states.keys.detect{ |m| m == params[:availability].to_sym}
      available_scope ||= :all
      @clients = @clients.public_send(available_scope)
    end
    # paginate
    @page = params[:page].presence || 1
    @clients = @clients.reorder(sort_string).page(@page.to_i).per(25)
    
    client_ids = @clients.map(&:id)

    @matches = ClientOpportunityMatch
              .group(:client_id)
              .where(client_id: client_ids)
              .count

    @active_filter = params[:availability].present? || params[:veteran].present?
    @available_clients = @clients.available
    @unavailable_clients = @clients.unavailable
  end

  # GET /clients/1
  def show
    @client_notes = @client.client_notes
    @client_note = ClientNote.new
  end

  def update
    if @client.update(client_params)
      # If we have a future prevent_matching_until date, remove the client from 
      # any current matches
      if @client.prevent_matching_until.present? && @client.prevent_matching_until > Date.today
        @client.unavailable(permanent: false)
      end
      redirect_to client_path(@client), notice: "Client updated"
    else
      render :show, {flash: {error: 'Unable update client.'}}
    end
  end

  # PATCH /clients/:id/unavailable
  # Find any matches where the client is the active client
  # Remove the client from the match
  # Activate the next client
  # Remove the client from any other proposed matches
  # Mark the Client as available = false
  def unavailable
    @client.unavailable(permanent: true)
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
      permit(:source, :release_of_information, :prevent_matching_until, :dmh_eligible, :va_eligible, :hues_eligible, :confidential)
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

end
