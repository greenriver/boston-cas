###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module ProgramDetailsHelper

  def form_url
    if params[:sub_program_id].present?
      program_sub_program_program_details_path(@program, params[:sub_program_id])
    else
      program_details_path(@program)
    end
  end

end
