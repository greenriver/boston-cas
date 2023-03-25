###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_view_available_services!
  before_action :require_can_edit_available_services!, only: [:update, :destroy, :create]
  before_action :set_service, only: [:show, :edit, :update, :destroy]

  # GET /services
  def index
    @services = Service.all
  end

    # GET /services/new
  def new
    @service = Service.new
  end

  # GET /services/1/edit
  def edit
  end

  # POST /services
  def create
    @service = Service.new(service_params)

    if @service.save
      redirect_to action: :index
      flash[:notice] = "Service <strong>#{@service.name}</strong> was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /services/1
  def update
    if @service.update(service_params)
      redirect_to action: :index
      flash[:notice] = "Service <strong>#{@service.name}</strong> was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /services/1
  def destroy
    @service.destroy
    redirect_to services_url, notice: "Service <strong>#{@service.name}</strong> was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service
      @service = Service.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def service_params
      params.require(:service).permit(
        :name,
        requirements_attributes: [:id, :rule_id, :positive, :variable, :_destroy]
      )
    end
end
