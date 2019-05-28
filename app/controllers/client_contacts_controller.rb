class ClientContactsController < ApplicationController
  include PjaxModalController

  before_action :set_client
  before_action :set_client_contacts
  before_action :set_current_contact

  def edit
  end

  def update
    saved = @client_contacts.update(client_contacts_params)
    unless request.xhr?
      if saved
        flash[:notice] = "Default Client Contacts updated"
        redirect_to client_path(@client)
      else
        raise @client_contacts.errors.full_messages.inspect
        flash[:error] = "Please review the form problems below."
        redirect_to :edit
      end
    end
  end

  private

  def set_client
    @client = Client.find params[:client_id].to_i
  end

  def set_client_contacts
    @client_contacts = @client.default_client_contacts
  end

  def set_current_contact
    @current_contact = current_contact
  end

  def client_contacts_params
    base_params = params[:client_contacts] || ActionController::Parameters.new
    base_params.permit(
        shelter_agency_contact_ids: [],
        housing_subsidy_admin_contact_ids: [],
        dnd_staff_contact_ids: [],
        regular_contact_ids: [],
        ssp_contact_ids: [],
        hsp_contact_ids: [],
        do_contact_ids: []
    ).tap do |result|
      result[:shelter_agency_contact_ids] = result[:shelter_agency_contact_ids]&.map(&:to_i) || []
      result[:regular_contact_ids] = result[:regular_contact_ids]&.map(&:to_i) || []
      result[:dnd_staff_contact_ids] = result[:dnd_staff_contact_ids]&.map(&:to_i) || []
      result[:housing_subsidy_admin_contact_ids] = result[:housing_subsidy_admin_contact_ids]&.map(&:to_i) || []
      result[:ssp_contact_ids] = result[:ssp_contact_ids]&.map(&:to_i) || []
      result[:hsp_contact_ids] = result[:hsp_contact_ids]&.map(&:to_i) || []
      result[:do_contact_ids] = result[:do_contact_ids]&.map(&:to_i) || []
    end
  end

  private

    def contact_owner_source
      Client
    end

    def contact_join_model_source
      @contact_owner.client_contacts
    end

    def join_model_class
      ClientContact
    end

end