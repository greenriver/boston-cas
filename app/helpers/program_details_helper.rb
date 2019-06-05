###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
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