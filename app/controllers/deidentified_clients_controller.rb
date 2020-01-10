###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class DeidentifiedClientsController < NonHmisClientsController
  before_action :require_can_enter_deidentified_clients!
  before_action :require_can_manage_deidentified_clients!, only: [:edit, :update, :destroy]

  def create
    @non_hmis_client = client_source.create(clean_params(deidentified_client_params))
    respond_with(@non_hmis_client, location: deidentified_clients_path)
  end

  def update
    @non_hmis_client.update(clean_params(deidentified_client_params))
    respond_with(@non_hmis_client, location: deidentified_clients_path)
  end

  def destroy
    @non_hmis_client.destroy
    respond_with(@non_hmis_client, location: deidentified_clients_path)
  end

  def choose_upload
    @upload = DeidentifiedClientsXlsx.new
  end

  def import
    if !params[:deidentified_clients_xlsx]&.[](:file)
      @upload = DeidentifiedClientsXlsx.new
      flash[:alert] = _("You must attach a file in the form.")
      render :choose_upload
      return
    end

    file = import_params[:file]
    begin
      @upload = DeidentifiedClientsXlsx.create(
        filename: file.original_filename,
        user_id: current_user.id,
        content_type: file.content_type,
        content: file.read,
      )
    rescue
      @upload = DeidentifiedClientsXlsx.new
      flash[:alert] = _("Cannot read uploaded file, is it an XLSX?")
      render :choose_upload
      return
    end

    if ! @upload.valid_header?
      @upload = DeidentifiedClientsXlsx.new
      flash[:alert] = _("Uploaded file does not have the correct header. Incorrect file?")
      render :choose_upload
      return
    end

    @upload.import(current_user.agency)
  end

  def client_source
    DeidentifiedClient.deidentified.visible_to(current_user)
  end

  def sort_options
    [
        {title: 'Client Identifier A-Z', column: 'client_identifier', direction: 'asc', order: 'LOWER(client_identifier) ASC', visible: true},
        {title: 'Client Identifier Z-A', column: 'client_identifier', direction: 'desc', order: 'LOWER(client_identifier) DESC', visible: true},
        {title: 'Agency A-Z', column: 'agency', direction: 'asc', order: 'LOWER(agency) ASC', visible: true},
        {title: 'Agency Z-A', column: 'agency', direction: 'desc', order: 'LOWER(agency) DESC', visible: true},
        {title: 'Assessment Score', column: 'assessment_score', direction: 'desc', order: 'assessment_score DESC', visible: true},
        {title: 'Days Homeless in the Last 3 Years', column: 'days_homeless_in_the_last_three_years', direction: 'desc',
            order: 'days_homeless_in_the_last_three_years DESC', visible: true},
    ]
  end
  helper_method :sort_options

  def filter_terms
    [ :agency, :cohort, :available ]
  end
  helper_method :filter_terms

  private
    def deidentified_client_params
      params.require(:deidentified_client).permit(
        :client_identifier,
        :assessment_score,
        :vispdat_score,
        :vispdat_priority_score,
        :veteran,
        :agency_id,
        :contact_id,
        :date_of_birth,
        :ssn,
        :days_homeless_in_the_last_three_years,
        :date_days_homeless_verified,
        :who_verified_days_homeless,
        :veteran,
        :rrh_desired,
        :youth_rrh_desired,
        :rrh_assessment_contact_info,
        :income_maximization_assistance_requested,
        :pending_subsidized_housing_placement,
        :family_member,
        :calculated_chronic_homelessness,
        :gender,
        :available,
        :income_total_monthly,
        :disabling_condition,
        :physical_disability,
        :developmental_disability,
        :domestic_violence,
        :interested_in_set_asides,
        :actively_homeless,
        :active_cohort_ids => [],
        :neighborhood_interests => [],
      ).merge(identified: false)
    end

    def append_client_identifier dirty_params
      dirty_params[:last_name] = "Anonymous - #{dirty_params[:client_identifier]}"
      dirty_params[:first_name] = "Anonymous - #{dirty_params[:client_identifier]}"
      return dirty_params
    end

    def clean_params dirty_params
      dirty_params[:active_cohort_ids] = dirty_params[:active_cohort_ids]&.reject(&:blank?)&.map(&:to_i)
      dirty_params[:active_cohort_ids] = nil if dirty_params[:active_cohort_ids].blank?
      dirty_params[:neighborhood_interests] = dirty_params[:neighborhood_interests]&.reject(&:blank?)&.map(&:to_i)
      if can_edit_all_clients?
        contact_agency_id = agency_id_for_contact(dirty_params[:contact_id])
        dirty_params[:agency_id] = contact_agency_id if contact_agency_id.present?
      else
        dirty_params[:agency_id] = current_user.agency_id
      end
      return append_client_identifier(dirty_params)
    end

    def import_params
      params.require(:deidentified_clients_xlsx).permit(
        :file
      )
    end

    def client_type
      _('De-Identified Clients')
    end
end
