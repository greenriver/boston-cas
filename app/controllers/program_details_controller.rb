###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
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
    @program.update(program_params)
    respond_with(@program, location: edit_program_sub_program_program_details_path)
  end

  private def set_program
    @program = program_scope.find_by(id: params[:program_id])
  end

  private def set_subprogram
    @subprogram = @program.sub_programs.find_by(id: params[:sub_program_id])
  end

  private def program_params
    params.require(:program).
      permit(
        :name,
        :description,
        :contract_start_date,
        :funding_source_id,
        :confidential,
        :eligibility_requirement_notes,
        :match_route_id,
        warehouse_project_ids: [],
        service_ids: [],
        requirements_attributes: [
          :id,
          :rule_id,
          :positive,
          :variable,
          :_destroy,
        ],
      )
  end
end
