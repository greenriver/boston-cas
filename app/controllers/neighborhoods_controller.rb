class NeighborhoodsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_manage_neighborhoods!
  before_action :set_neighborhood, only: [:edit, :update, :destroy]

  def index
    @neighborhoods = if params[:q].present?
                       neighborhood_scope.text_search(params[:q])
                     else
                       neighborhood_scope
    end

    @neighborhoods = @neighborhoods.page(params[:page])
  end

  def new
    @neighborhood = Neighborhood.new
  end

  def create
    if @neighborhood = Neighborhood.create(neighborhood_params)
      flash[:notice] = "#{@neighborhood.name} was successfully added."
      redirect_to neighborhoods_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @neighborhood.update(neighborhood_params)
      flash[:notice] = "#{@neighborhood.name} was successfully updated."
      redirect_to neighborhoods_path
    else
      render :edit
    end
  end

  def destroy
    @neighborhood.destroy
    flash[:notice] = "#{@neighborhood.name} was successfully deleted."
    redirect_to neighborhoods_path
  end

  def set_neighborhood
    @neighborhood = neighborhood_scope.find(params[:id])
  end

  def neighborhood_params
    params.require(:neighborhood).permit(:name)
  end

  def neighborhood_scope
    Neighborhood.order(:name)
  end
end
