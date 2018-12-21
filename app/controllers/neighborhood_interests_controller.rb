class NeighborhoodInterestsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_edit_all_clients!
  before_action :set_client_id

  def create
    neighborhood_interests_parms[:neighborhood_id].reject(&:empty?).each do | neighborhood_id |
      NeighborhoodInterest.create(client_id: @client_id, neighborhood_id: neighborhood_id)
    end
    redirect_to client_path(@client_id)
  end

  def destroy
    interest = NeighborhoodInterest.find(params.require(:id))
    interest.destroy
    redirect_to client_path(@client_id)
  end

  def neighborhood_interests_parms
    params.require(:neighborhood_interest).
      permit(neighborhood_id: [])
  end

  def set_client_id
    @client_id = params.require(:client_id)
  end
end