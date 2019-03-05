class ProgramDetailsController < ApplicationController
  
  before_action :authenticate_user!
  before_action :set_program
  before_action :set_subprogram
  before_action :check_edit_permission!, only: [:edit, :update]

  def edit
  end

  def update
    if @program.update program_params
      flash[:notice] = 'Program Details saved.'
      redirect_to action: :edit
    else
      render :edit
    end
  end

  private
    def program_scope
      if can_view_programs?
        return Program.all
      elsif can_view_assigned_programs?
        return Program.visible_by(current_user)
      else
        not_authorized!
      end
    end

    def check_edit_permission!
      not_authorized! unless can_edit_programs? || (can_edit_assigned_programs? && @subprogram.editable_by?(current_user))
    end

    def set_program
      @program = program_scope.find(params[:program_id])
    end

    def set_subprogram
      @subprogram = @program.sub_programs.find params[:sub_program_id]
    end

    def program_params
      params.require(:program).
        permit(
          :name, 
          :contract_start_date, 
          :funding_source_id,
          :confidential,
          :eligibility_requirement_notes,
          :match_route_id,
          service_ids: [],
          requirements_attributes: [:id, :rule_id, :positive, :variable, :_destroy]
        )
    end

end
