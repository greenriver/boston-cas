module ProgramDetailsHelper
  
  def form_url
    if params[:sub_program_id].present?
      program_sub_program_program_details_path(@program, params[:sub_program_id])
    else
      program_details_path(@program)
    end
  end
  
end