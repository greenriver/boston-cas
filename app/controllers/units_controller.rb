###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class UnitsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_view_units!
  before_action :require_can_edit_units!, only: [:update, :destroy, :create]
  before_action :set_unit, only: [:show, :edit, :update, :destroy]
  helper_method :sort_column, :sort_direction
  include AjaxModalRails::Controller

  # GET /hmis/units
  def index
    # search
    @units = if params[:q].present?
      unit_scope.text_search(params[:q])
    else
      unit_scope
    end

    if params[:current_tab] == 'Inactive'
      @units = @units.inactive
      @current_tab_name = 'Inactive'
    else
      @units = @units.active
      @current_tab_name = 'Active'
    end

    # sort / paginate
    @units = @units
      .order(sort_column => sort_direction)
      .preload(:building)
      .page(params[:page]).per(25)
  end

  # GET /hmis/units/1
  def show
  end

  # GET /hmis/units/new
  def new
    @unit = Unit.new
    set_building
  end

  # GET /hmis/units/1/edit
  def edit
  end

  # POST /hmis/units
  def create
    @unit = Unit.new(unit_params)
    if @unit.save
      if @unit[:available]
        # make sure we have an opportunity with the associated unit
        # Or not, since we don't want to double up on opportunities with vouchers that
        # might also include this unit
        # op = Opportunity.where(unit_id: @unit[:id]).first_or_create(unit: @unit, available: true)
      end
      @unit.apply_default_housing_attributes
      redirect_to building_path(@unit.building)
      flash[:notice] = "Unit <strong>#{@unit[:name]}</strong> in <a href=\"#{building_path(@unit.building)}\">#{@unit.building.name}</a> was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /hmis/units/1
  def update
    if @unit.update(unit_params)
      if @unit[:available]
        # make sure we have an opportunity with the associated unit
        # Or not, since we don't want to double up on opportunities with vouchers that
        # might also include this unit
        # op = Opportunity.where(unit_id: @unit[:id]).first_or_create(unit: @unit, available: true)
      end
      redirect_to building_path(@unit.building) unless ajax_modal_request?
      flash[:notice] = "Unit <strong>#{@unit[:name]}</strong> was successfully updated."
    else
      render :edit, { flash: { error: "Unable to update unit <strong>#{@unit[:name]}</strong>." } }
    end
  end

  # DELETE /hmis/units/1
  def destroy
    previous_page = Rails.application.routes.recognize_path(request.referrer)
    next_url = if previous_page[:controller] == 'units' && previous_page[:action] == 'edit'
      building_path(@unit.building)
    else
      request.referer
    end

    if @unit.destroy
      redirect_to next_url, notice: "Unit <strong>#{@unit[:name]}</strong> was successfully deleted."
    else
      redirect_to next_url, { flash: { error: "Unable to delete unit <strong>#{@unit[:name]}</strong>." } }
    end
  end

  # POST /hmis/units/1/restore
  def restore
    @unit = Unit.find(params[:id])
    @unit.update(active: true)
    redirect_back(fallback_location: units_path, notice: "Unit <strong>#{@unit[:name]}</strong> was restored.")
  end

  # POST /hmis/units/1/deactivate
  def deactivate
    @unit = Unit.find(params[:unit_id])
    @unit.update(active: false)
    redirect_back(fallback_location: units_path, notice: "Unit <strong>#{@unit[:name]}</strong> was deactivated.")
  end

  private

  def unit_scope
    Unit
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_unit
    @unit = Unit.find(params[:id])
  end

  def set_building
    @unit.building = Building.find(params[:building_id]) if params[:building_id]
  end

  # Only allow a trusted parameter "white list" through.
  def unit_params
    params.require(:unit).permit(
      :name,
      :available,
      :building_id,
      :elevator_accessible,
      requirements_attributes: [:id, :rule_id, :positive, :variable, :_destroy],
    )
  end

  def filter_params
    params.permit(:q, :direction, :sort)
  end
  helper_method :filter_params

  def sort_column
    Unit.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def sort_direction
    ['asc', 'desc'].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def query_string
    "%#{@query}%"
  end
end
