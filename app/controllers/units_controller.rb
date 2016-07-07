class UnitsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_dnd_staff!
  before_action :set_unit, only: [:show, :edit, :update, :destroy]
  helper_method :sort_column, :sort_direction

  # GET /hmis/units
  def index
    # search
    @units = if params[:q].present?
      unit_scope.text_search(params[:q])
    else
      unit_scope
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
        #op = Opportunity.where(unit_id: @unit[:id]).first_or_create(unit: @unit, available: true)
      end
      redirect_to building_path(@unit.building)
      flash[:notice] = "Unit <strong>#{@unit[:name]}</strong> was successfully updated."
    else
      render :edit, {:flash => { :error => 'Unable to update unit <strong>#{@unit[:name]}</strong>.'}}
    end
  end

  # DELETE /hmis/units/1
  def destroy
    if @unit.destroy
      redirect_to units_path, notice: "Unit <strong>#{@unit[:name]}</strong> was successfully deleted."
    else
      render :edit, {:flash => { :error => 'Unable to delete unit <strong>#{@unit[:name]}</strong>.'}}
    end
  end

  # RESTORE /hmis/units/1
  def restore
    if Unit.restore(params[:id])
      @unit = Unit.find(params[:id])
      redirect_to units_path, notice: "Unit <strong>#{@unit[:name]}</strong> successfully restored."
    else
      render :edit, {:flash => { :error => 'Unable to restore unit.'}}
    end
  end

  def get_unit
    @unit = Unit.find(params[:id])
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
      if params[:building_id]
        @unit.building = Building.find(params[:building_id])
      end
    end
    # Only allow a trusted parameter "white list" through.
    def unit_params
      params.require(:unit).permit(:name, :available, :building_id)
    end

    def sort_column
      Unit.column_names.include?(params[:sort]) ? params[:sort] : 'id'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def query_string
      "%#{@query}%"
    end

end
