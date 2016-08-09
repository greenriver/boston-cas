class SubProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_add_vacancies!
  before_action :set_program
  before_action :set_sub_program, only: [:edit, :update, :destroy]

  def new
    program = Program.find(params[:program_id])
    @subprogram = SubProgram.new({program_type: 'Project-Based', program: program})

  end
  def edit
  end

  def create
    @subprogram = sub_program_source.new
    @subprogram.assign_attributes sub_program_params
    prevent_incorrect_building()
    if @subprogram.save
      redirect_to action: :index, controller: :programs
      flash[:notice] = "#{@subprogram.program.name} created."
    else
      flash[:error] = "Please review the form problems below."
      render :new
    end
  end

  def update
    @subprogram.assign_attributes(sub_program_params)
    prevent_incorrect_building()
    if @subprogram.save
      redirect_to action: :index, controller: :programs
      flash[:notice] = "Program \"<a href=\"#{edit_program_sub_program_path(@subprogram.program, @subprogram)}\">#{@subprogram.program.name}</a>\" updated."
    else
      flash[:error] = "Please review the form problems below."
      render :new
    end
  end

  def destroy
  end

  private
  # Only allow a trusted parameter "white list" through.
  def sub_program_params
    params.require(:sub_program).
      permit(
        :id,
        :name,
        :voucher_count,
        :subgrantee_id, # Service provider
        :sub_contractor_id,
        :program_type,
        :building_id,
        :hsa_id
      )
  end

  def sub_program_source
    @program.sub_programs
  end

  def sub_program_scope
    SubProgram.all
  end
  # Use callbacks to share common setup or constraints between actions.

  def set_program
    @program = Program.find(params[:program_id])
  end

  def set_sub_program
    @subprogram = sub_program_scope.find(params[:id])
  end
  def prevent_incorrect_building
    # make sure we unset the building if we shouldn't have one.
    unless @subprogram.has_buildings
      @subprogram.building_id = nil
    end
  end
  
end
