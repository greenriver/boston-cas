class ProgramDetailsController < ApplicationController
  
  before_action :authenticate_user!
  before_action :require_can_view_programs!
  before_action :require_can_edit_programs!, only: [:create, :update, :destroy]
  before_action :set_program
  before_action :set_subprogram

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
      Program.all
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
