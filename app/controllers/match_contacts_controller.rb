class MatchContactsController < ApplicationController
  include PjaxModalController
  include HasMatchAccessContext
  include ContactEditPermissions

  skip_before_action :authenticate_user!
  before_action :require_match_access_context!
  before_action :set_match
  before_action :require_current_contact_can_edit_match_contacts!
  before_action :set_match_contacts
  before_action :set_current_contact

  def edit
  end

  def update
    update_params = match_contacts_params
    saved = @match_contacts.update(update_params)
    unless request.xhr?
      if saved
        flash[:notice] = 'Match Contacts updated'
        redirect_to match_path(@match)
      else
        raise @match_contacts.errors.full_messages.inspect
        flash[:error] = 'Please review the form problems below.'
        redirect_to :edit
      end
    end
  end

  private

  def match_scope
    ClientOpportunityMatch.all
  end

  def set_match
    @match = match_scope.find params[:match_id]
  end

  def set_current_contact
    @current_contact = current_contact
  end

  def set_match_contacts
    @match_contacts = @match.match_contacts
  end

  def match_contacts_params
    base_params = params[:match_contacts] || ActionController::Parameters.new
    base_params.permit(
      shelter_agency_contact_ids: [],
      housing_subsidy_admin_contact_ids: [],
      dnd_staff_contact_ids: [],
      client_contact_ids: [],
      ssp_contact_ids: [],
      hsp_contact_ids: [],
      do_contact_ids: [],
    ).tap do |result|
      if current_contact.user_can_edit_match_contacts?
        result[:shelter_agency_contact_ids] ||= []
        result[:client_contact_ids] ||= []
        result[:dnd_staff_contact_ids] ||= []
        result[:housing_subsidy_admin_contact_ids] ||= []
        result[:ssp_contact_ids] ||= []
        result[:hsp_contact_ids] ||= []
        result[:do_contact_ids] ||= []
      elsif hsa_can_edit_contacts?
        # only allow editing of the hsa contacts
        result[:shelter_agency_contact_ids] = @match.shelter_agency_contact_ids
        result[:client_contact_ids] = @match.client_contact_ids
        result[:dnd_staff_contact_ids] = @match.dnd_staff_contact_ids
        result[:housing_subsidy_admin_contact_ids] ||= []
        result[:ssp_contact_ids] = @match.ssp_contact_ids
        result[:hsp_contact_ids] = @match.hsp_contact_ids
        result[:do_contact_ids] = @match.do_contact_ids
        # always add self
        result[:housing_subsidy_admin_contact_ids] << current_contact.id unless result[:housing_subsidy_admin_contact_ids].map(&:to_i).include? current_contact.id
      end
    end
  end

  def require_current_contact_can_edit_match_contacts!
    not_authorized! unless current_contact.user_can_edit_match_contacts? || hsa_can_edit_contacts?
  end
end
