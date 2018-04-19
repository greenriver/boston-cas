class ProgramContactsController < ApplicationController
  include PjaxModalController

  before_action :require_can_edit_programs!
  before_action :set_program
  before_action :set_program_contacts

  def edit
  end
  
  def update
    if @program_contacts.update program_contacts_params
      flash[:notice] = "Contacts updated"
      redirect_to edit_program_sub_program_contacts_path(@program, @subprogram)
    else
      flash[:error] = "Please review the form problems below."
      render :edit
    end
  end
  
  private
  
    def program_scope
      Program.all
    end

    def sub_program_scope
      SubProgram.all
    end
  
    def set_program
      @program = program_scope.find params[:program_id].to_i
      @subprogram = sub_program_scope.find params[:sub_program_id].to_i
    end
  
    def set_program_contacts
      @program_contacts = @program.default_match_contacts
    end
    
    def program_contacts_params
      base_params = params[:program_contacts] || ActionController::Parameters.new
      base_params.permit(
        shelter_agency_contact_ids: [],
        housing_subsidy_admin_contact_ids: [],
        dnd_staff_contact_ids: [],
        client_contact_ids: [],
        ssp_contact_ids: [],
        hsp_contact_ids: []
      ).tap do |result|
        result[:shelter_agency_contact_ids] ||= []
        result[:client_contact_ids] ||= []
        result[:dnd_staff_contact_ids] ||= []
        result[:housing_subsidy_admin_contact_ids] ||= []
        result[:ssp_contact_ids] ||= []
        result[:hsp_contact_ids] ||= []
      end
    end  
    
  
end