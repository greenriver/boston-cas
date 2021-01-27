###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ProgramDetailsController < ApplicationController
  include ProgramPermissions

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
    def set_program
      @program = program_scope.find_by(id: params[:program_id])
    end

    def set_subprogram
      @subprogram = @program.sub_programs.find params[:sub_program_id]
    end

    def program_params
      params.require(:program).
        permit(
          :name,
          :description,
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
