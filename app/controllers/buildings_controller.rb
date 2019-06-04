###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class BuildingsController < ApplicationController
  include HasMatchAccessContext

  before_action :authenticate_user!, except: [:available_move_in_units]
  before_action :require_match_access_context!, only: [:available_move_in_units]

  before_action :require_can_view_buildings!, except: [:available_units, :available_move_in_units]
  before_action :require_can_add_vacancies!, only: [:available_units]
  before_action :require_can_edit_buildings!, only: [:update, :destroy, :create]
	before_action :set_building, only: [:show, :edit, :update, :destroy, :available_units, :available_move_in_units, :units]
  before_action :set_show_confidential_names
  helper_method :sort_column, :sort_direction

	# GET /hmis/buildings
  def index
    # search
    @buildings = if params[:q].present?
      building_scope.text_search(params[:q])
    else
      building_scope
    end

    # sort / paginate
    column = "buildings.#{sort_column}"
    if sort_column == 'subgrantee_id'
      column = 'subgrantees.name'
    end
    sort = "#{column} #{sort_direction}"

    @buildings = @buildings
      .includes(:subgrantee)
      .references(:subgrantee)
      .order(sort)
      .preload(:subgrantee)
      .page(params[:page]).per(25)
  end

  # GET /hmis/buildings/1
  def show
  end

  def new
    @building = Building.new
  end

  def create
    if @building = Building.create(building_params)
      flash[:notice] = "#{@building.name} was successfully added."
      redirect_to buildings_path @building
    else
      render :new
    end
  end

	# Get /hmis/buildings/1/edit
  def edit

  end

  # PATCH/PUT /hmis/buildings/1
  def update
    if @building.update(building_params)
    	flash[:notice] = "#{@building.name} was successfully updated."
      redirect_to buildings_path @building
    else
      render :edit
    end
  end

  def available_units
    @available_units = @building.available_units_for_vouchers
    respond_to do |format|
      format.json { render json: @available_units, only: [:id, :name, :building_id] }
    end
  end

  # Forwarder to allow different access control
  def available_move_in_units
    available_units
  end

  def units
    @units = @building.units_for_vouchers
    respond_to do |format|
      format.json { render json: @units, only: [:id, :name, :building_id] }
    end
  end

  def show_confidential_names?
    @show_confidential_names
  end
  helper_method :show_confidential_names?

	private
    def building_scope
      Building.all
    end
  
    def set_building
      @building = building_scope.find(params[:id])
    end

    def set_show_confidential_names
      @show_confidential_names = can_view_client_confidentiality? && params[:confidential_override].present?
    end

    def building_params
      params.require(:building).permit(
        :name, :building_type, :subgrantee_id, :address, :city, :state, :zip_code,
        service_ids: [],
        requirements_attributes: [:id, :rule_id, :positive, :variable, :_destroy]
      )
    end

    def sort_column
      Building.column_names.include?(params[:sort]) ? params[:sort] : 'id'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def query_string
      "%#{@query}%"
    end

end
