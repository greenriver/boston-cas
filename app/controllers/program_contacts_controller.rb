class ProgramContactsController < ApplicationController
  include PjaxModalController
  include ProgramPermissions

  before_action :set_program
  before_action :set_program_contacts
  before_action :check_edit_permission!

  def edit
  end

  def update
    saved = @program_contacts.update program_contacts_params
    unless request.xhr?
      if saved
        flash[:notice] = 'Contacts updated'
        redirect_to edit_program_sub_program_contacts_path(@program, @subprogram)
      else
        raise @program_contacts.errors.full_messages.inspect
        flash[:error] = 'Please review the form problems below.'
        redirect_to edit_program_sub_program_contacts_path(@program, @subprogram)
      end
    end
  end

  def hsa_can_edit_contacts?
    @program.match_route.contacts_editable_by_hsa
  end
  helper_method :hsa_can_edit_contacts?

  private

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
      hsp_contact_ids: [],
      do_contact_ids: [],
    ).tap do |result|
      result[:shelter_agency_contact_ids] = result[:shelter_agency_contact_ids]&.map(&:to_i) || []
      result[:client_contact_ids] = result[:client_contact_ids]&.map(&:to_i) || []
      result[:dnd_staff_contact_ids] = result[:dnd_staff_contact_ids]&.map(&:to_i) || []
      result[:housing_subsidy_admin_contact_ids] = result[:housing_subsidy_admin_contact_ids]&.map(&:to_i) || []
      result[:ssp_contact_ids] = result[:ssp_contact_ids]&.map(&:to_i) || []
      result[:hsp_contact_ids] = result[:hsp_contact_ids]&.map(&:to_i) || []
      result[:do_contact_ids] = result[:do_contact_ids]&.map(&:to_i) || []
    end
  end
end
