class SubProgramsController < ApplicationController
  include ProgramPermissions

  before_action :authenticate_user!
  before_action :require_can_edit_programs!, only: [:destroy, :create]
  before_action :set_program
  before_action :set_sub_program, only: [:edit, :update, :destroy]

  def new
    program = Program.find(params[:program_id])
    @subprogram = SubProgram.new(program_type: 'Project-Based', program: program)
  end

  def edit
    @available_file_tags = FileTag.available_tags
  end

  def create
    @subprogram = SubProgram.new
    @subprogram.assign_attributes sub_program_params
    prevent_incorrect_building
    if @subprogram.save
      redirect_to action: :index, controller: :programs
      flash[:notice] = "#{@subprogram.program.name} created."
    else
      flash[:error] = 'Please review the form problems below.'
      render :new
    end
  end

  def update
    @subprogram.assign_attributes(sub_program_params)
    prevent_incorrect_building
    if @subprogram.save
      @subprogram.file_tags.destroy_all
      if file_tag_params.any? && Warehouse::Base.enabled?
        tags = Warehouse::Tag.where(id: file_tag_params).map do |tag|
          @subprogram.file_tags.create(tag_id: tag.id, name: tag.name)
        end
      end
      redirect_to action: :edit
      flash[:notice] = "Program \"<a href=\"#{edit_program_sub_program_path(@subprogram.program, @subprogram)}\">#{@subprogram.program.name}</a>\" updated."
    else
      flash[:error] = 'Please review the form problems below.'
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
        :hsa_id,
        :confidential,
        :eligibility_requirement_notes,
      )
  end

  def file_tag_params
    params.require(:sub_program)[:file_tag_ids].
      map(&:presence).compact.map(&:to_i) || []
  end

  def check_edit_permission!
    not_authorized! unless can_edit_programs? || (can_edit_assigned_programs? && @subprogram.editable_by?(current_user))
  end

  def program_scope
    if can_view_programs?
      Program.all
    elsif can_view_assigned_programs?
      Program.visible_by(current_user)
    else
      not_authorized!
    end
  end

  def sub_program_scope
    if can_view_programs?
      SubProgram.all
    elsif can_view_assigned_programs?
      SubProgram.visible_by(current_user)
    else
      not_authorized!
    end
  end

  # Use callbacks to share common setup or constraints between actions.

  def set_program
    @program = program_scope.find(params[:program_id])
  end

  def set_sub_program
    @subprogram = sub_program_scope.find(params[:id])
    check_edit_permission!
  end

  def prevent_incorrect_building
    # make sure we unset the building if we shouldn't have one.
    unless @subprogram.has_buildings?
      @subprogram.building_id = nil
    end
  end
end
