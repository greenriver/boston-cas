class OpportunitiesController < ApplicationController
  require 'securerandom'

  before_action :authenticate_user!
  before_action :require_add_vacancies!
  before_action :set_opportunity, only: [:show, :edit, :update, :destroy]
  helper_method :sort_column, :sort_direction

  # GET /hmis/opportunities
  def index
    # search
    @opportunities = if params[:q].present?
      opportunity_scope.text_search(params[:q])
    else
      opportunity_scope
    end

    # sort / paginate
    @opportunities = @opportunities
      .order(sort_column => sort_direction)
      .preload(:unit, :voucher)
      .page(params[:page]).per(25)

    @matches = ClientOpportunityMatch.group(:opportunity_id)
                .where(opportunity_id: @opportunities.map(&:id))
                .count
    
  end

  # GET /hmis/opportunities/1
  def show
  end

  # GET /hmis/opportunities/new
  # Using this to bulk create units and associated vouchers
  def new
    @opportunity = Opportunity.new
    @programs = sub_program_scope.where(program_type: SubProgram.have_buildings)
    @buildings = building_scope
  end

  # GET /hmis/opportunities/1/edit
  def edit
  end

  # Bulk create available units with associated available vouchers
  def create
    @opportunity = Opportunity.new
    @programs = sub_program_scope.where(program_type: 'Project-Based')
    @buildings = building_scope
    
    if params[:opportunity][:program].nil? || params[:opportunity][:program].empty? 
      @opportunity.errors[:program] = 'Required'
    end
    if params[:opportunity][:building].nil? || params[:opportunity][:building].empty?
      @opportunity.errors[:building] = 'Required'
    end
    if params[:opportunity][:units].nil? || params[:opportunity][:units].empty? || ! params[:opportunity][:units] =~ /\A\d+\z/
      @opportunity.errors[:units] = 'Required, and must be a number'
    end

    if @opportunity.errors.present?
      render :new
    else
      building = Building.find(opportunity_params[:building].to_i)
      sub_program = SubProgram.find(opportunity_params[:program].to_i)
      units = []
      vouchers = []
      opportunity_params[:units].to_i.times do |x|
        unit = Unit.create(building: building, name: SecureRandom.hex, available: true)
        voucher = Voucher.create(sub_program: sub_program, unit: unit, available: true)
        voucher.opportunity || voucher.create_opportunity(available: true, available_candidate: true)
        
        units << unit
        vouchers << voucher
      end
      if units.count > 0 && vouchers.count > 0
        flash[:notice] = "Created #{vouchers.count} new #{Opportunity.model_name.human(count: units.count)}"
        Matching::RunEngineJob.perform_later
      else
        flash[:alert] = "There was an error creating new #{Opportunity.model_name.human}"
      end
        redirect_to action: :index
    end
  end

  # PATCH/PUT /hmis/opportunities/1
  def update
    if @opportunity.update(opportunity_params)
      redirect_to opportunity_path(@opportunity), notice: "Opportunity <strong>#{@opportunity[:id]}</strong> was successfully updated."
    else
      render :edit, {flash: {error: 'Unable to update opportunity <strong>#{@opportunity[:name]}</strong>.'}}
    end
  end

  # DELETE /hmis/opportunities/1
  def destroy
    if @opportunity.destroy
      redirect_to opportunities_path, notice: "Opportunity <strong>#{@opportunity[:id]}</strong> was successfully deleted."
    else
      render :edit, {flash: { error: 'Unable to delete opportunity <strong>#{@opportunity[:name]}</strong>.'}}
    end
  end

  # RESTORE /hmis/opportunities/1
  def restore
    if Opportunity.restore(params[:opportunity_id])
      @opportunity = Opportunity.find(params[:opportunity_id])
      redirect_to opportunities_path, notice: "Opportunity <strong>#{@opportunity[:id]}</strong> successfully restored."
    else
      render :edit, {:flash => { :error => 'Unable to restore opportunity.'}}
    end
  end

  def get_opportunity
    @opportunity = Opportunity.find(params[:id])
  end

  private
    def opportunity_scope
      Opportunity.where(success: false)
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_opportunity
      @opportunity = Opportunity.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def opportunity_params
      params.require(:opportunity)
        .permit(
          :available, 
          :unit, 
          :voucher, 
          :client,
          :program,
          :building,
          :units,
        )
    end

    # TODO: limit to programs you are associated with
    def sub_program_scope
      SubProgram.all
    end

    # TODO: limit to buildings you are associated with
    def building_scope
      Building.all
    end

    def sort_column
      Opportunity.column_names.include?(params[:sort]) ? params[:sort] : 'id'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def query_string
      "%#{@query}%"
    end

end
