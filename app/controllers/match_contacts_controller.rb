class MatchContactsController < ApplicationController
  include PjaxModalController
  include HasMatchAccessContext

  skip_before_action :authenticate_user!
  before_action :require_match_access_context!
  before_action :require_current_contact_can_edit_match_contacts!
  before_action :set_match
  before_action :set_match_contacts

  def edit
  end
  
  def update
    if @match_contacts.update match_contacts_params
      flash[:notice] = "Match Contacts updated"
      # TODO redirect back to specific decision if we came from there
      redirect_to access_context.match_path(@match)
    else
      flash[:error] = "Please review the form problems below."
      render :edit
    end
  end
  
  private
  
    def match_scope
      ClientOpportunityMatch.all
    end
  
    def set_match
      @match = match_scope.find params[:match_id]
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
    
    def require_current_contact_can_edit_match_contacts!
      not_authorized! unless current_contact.user_can_edit_match_contacts?
    end
    
    
  
end