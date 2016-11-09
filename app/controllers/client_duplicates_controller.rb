class ClientDuplicatesController < ApplicationController
  include PjaxModalController
  before_action :authenticate_user!
  before_action :require_can_edit_all_clients!
  before_action :set_clients, only: [:show, :update]

  def show

  end

  def update
    if @dupe.update_attributes(merged_into: @client.id, available: false, available_candidate: false)
      redirect_to client_path @client
      flash[:notice] = "Client <strong>#{@dupe.full_name}</strong> was merged into #{@client.full_name}."
    else
      render :edit, {flash: {error: 'Unable to merge 
        <strong>#{c.full_name}</strong> into client <strong>#{@client.full_name}</strong>.'}}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_clients
    @client = Client.find(params[:client_id])
    @dupe = Client.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def client_duplicate_params
    params.require(:client_id)
  end
end