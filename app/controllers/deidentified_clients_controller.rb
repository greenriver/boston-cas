###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class DeidentifiedClientsController < NonHmisClientsController
  include HasMatchAccessContext
  before_action :require_can_enter_deidentified_clients!, except: [:current_assessment_limited]
  before_action :require_match_access_context!, only: [:current_assessment_limited]
  before_action :require_can_manage_deidentified_clients!, only: [:destroy]

  def create
    @non_hmis_client = client_source.create(clean_params(deidentified_client_params))
    respond_with(@non_hmis_client, location: new_deidentified_client_non_hmis_assessment_path(@non_hmis_client))
  end

  def update
    add_shelter_history(clean_params(deidentified_client_params))
    @non_hmis_client.update(clean_params(deidentified_client_params))
    if pathways_enabled?
      # mark the client as available if this is a new assessment
      unless params[:assessment_id].present? || deidentified_client_params[:client_assessments_attributes].blank?
        @non_hmis_client.update(
          available: true,
          available_date: nil,
          available_reason: nil,
        )
      end

      @non_hmis_client.current_assessment&.update_assessment_score!

    end
    respond_with(@non_hmis_client, location: path_for_non_hmis_client)
  end

  def destroy
    if pathways_enabled? && params[:assessment_id].present?
      @non_hmis_client.non_hmis_assessments.find(params[:assessment_id].to_i).destroy
    else
      @non_hmis_client.destroy
    end
    respond_with(@non_hmis_client, location: deidentified_clients_path)
  end

  def choose_upload
    @upload = DeidentifiedClientsXlsx.new(agency_id: current_user.agency_id)
  end

  def import
    unless params[:deidentified_clients_xlsx]&.[](:file)
      @upload = DeidentifiedClientsXlsx.new(agency_id: current_user.agency_id)
      flash[:alert] = Translation.translate('You must attach a file in the form.')
      render :choose_upload
      return
    end

    file = import_params[:file]
    agency = Agency.find(import_params[:agency_id].to_i)
    update_availability = import_params[:update_availability].to_s.in?(['1', 'true'])

    unless agency.present?
      @upload = DeidentifiedClientsXlsx.new(agency_id: current_user.agency_id)
      flash[:alert] = Translation.translate('You must select a valid agency')
      render :choose_upload
      return
    end

    begin
      @upload = DeidentifiedClientsXlsx.create(
        filename: file.original_filename,
        user_id: current_user.id,
        content_type: file.content_type,
        content: file.read,
      )
    rescue StandardError
      @upload = DeidentifiedClientsXlsx.new(agency_id: current_user.agency_id)
      flash[:alert] = Translation.translate('Cannot read uploaded file, is it an XLSX?')
      render :choose_upload
      return
    end

    unless @upload.valid_header?
      @upload = DeidentifiedClientsXlsx.new(agency_id: current_user.agency_id)
      flash[:alert] = Translation.translate('Uploaded file does not have the correct header. Incorrect file?')
      render :choose_upload
      return
    end

    @upload.import(agency, update_availability: update_availability)
  end

  def assessment_type
    Config.get(:deidentified_client_assessment) || 'DeidentifiedClientAssessment'
  end

  def client_source
    DeidentifiedClient.deidentified.visible_to(current_user)
  end

  def sort_options
    [
      { title: 'Client Identifier A-Z', column: 'client_identifier', direction: 'asc', order: 'LOWER(client_identifier) ASC', visible: true },
      { title: 'Client Identifier Z-A', column: 'client_identifier', direction: 'desc', order: 'LOWER(client_identifier) DESC', visible: true },
      { title: 'Agency A-Z', column: 'agencies.name', direction: 'asc', order: 'LOWER(agencies.name) ASC', visible: true },
      { title: 'Agency Z-A', column: 'agencies.name', direction: 'desc', order: 'LOWER(agencies.name) DESC', visible: true },
      { title: 'Assessment Score', column: 'assessment_score', direction: 'desc', order: 'non_hmis_clients.assessment_score DESC', visible: true },
      { title: 'Assessment Date', column: 'assessed_at', direction: 'desc', order: 'non_hmis_clients.assessed_at DESC', visible: true },
      { title: 'Days Homeless in the Last 3 Years', column: 'days_homeless_in_the_last_three_years', direction: 'desc',
        order: 'days_homeless_in_the_last_three_years DESC', visible: true },
    ].freeze
  end
  helper_method :sort_options

  def filter_terms
    [:agency, :cohort, :available]
  end
  helper_method :filter_terms

  private def path_for_non_hmis_client
    deidentified_client_path(id: @non_hmis_client.id)
  end

  private def deidentified_client_params
    params.require(:deidentified_client).permit(
      :client_identifier,
      :agency_id,
      :contact_id,
      :race,
      :ethnicity,
      :gender,
      :available,
      :available_date,
      :available_reason,
      :limited_release_on_file,
      :full_release_on_file,
      :set_asides_housing_status,
      :is_currently_youth,
      :assessment_score,
      :vispdat_score,
      :vispdat_priority_score,
      :shelter_name,
      :warehouse_client_id,
      active_cohort_ids: [],
      client_assessments_attributes: [
        :id,
        :type,
        :entry_date,
        :assessment_score,
        :vispdat_score,
        :vispdat_priority_score,
        :veteran,
        :veteran_status,
        :actively_homeless,
        :days_homeless_in_the_last_three_years,
        :date_days_homeless_verified,
        :who_verified_days_homeless,
        :rrh_desired,
        :youth_rrh_desired,
        :rrh_assessment_contact_info,
        :income_maximization_assistance_requested,
        :income_total_monthly,
        :pending_subsidized_housing_placement,
        :family_member,
        :calculated_chronic_homelessness,
        :income_total_annual,
        :disabling_condition,
        :physical_disability,
        :developmental_disability,
        :domestic_violence,
        :interested_in_set_asides,
        :required_number_of_bedrooms,
        :required_minimum_occupancy,
        :requires_wheelchair_accessibility,
        :requires_elevator_access,
        :youth_rrh_aggregate,
        :dv_rrh_aggregate,
        :dv_rrh_desired,
        :veteran_rrh_desired,
        :rrh_th_desired,
        :sro_ok,
        :other_accessibility,
        :disabled_housing,
        :documented_disability,
        :evicted,
        :ssvf_eligible,
        :health_prioritized,
        :hiv_aids,
        :is_currently_youth,
        :case_manager_contact_info,
        :shelter_name,
        :phone_number,
        :email_addresses,
        :mailing_address,
        :day_locations,
        :night_locations,
        :other_contact,
        :household_size,
        :hoh_age,
        :current_living_situation,
        :pending_housing_placement_type,
        :pending_housing_placement_type_other,
        :maximum_possible_monthly_rent,
        :possible_housing_situation,
        :possible_housing_situation_other,
        :no_rrh_desired_reason,
        :no_rrh_desired_reason_other,
        :accessibility_other,
        :hiv_housing,
        :medical_care_last_six_months,
        :intensive_needs_other,
        :additional_homeless_nights,
        :homeless_night_range,
        :notes,
        {
          neighborhood_interests: [],
          provider_agency_preference: [],
          affordable_housing: [],
          high_covid_risk: [],
          service_need_indicators: [],
          intensive_needs: [],
          background_check_issues: [],
        },
      ],
    )
  end

  private def append_client_identifier dirty_params
    dirty_params[:last_name] = "Anonymous - #{dirty_params[:client_identifier]}"
    dirty_params[:first_name] = "Anonymous - #{dirty_params[:client_identifier]}"

    return dirty_params
  end

  private def clean_params dirty_params
    dirty_params = clean_client_params(dirty_params)

    return append_client_identifier(dirty_params)
  end

  private def import_params
    params.require(:deidentified_clients_xlsx).permit(
      :file,
      :agency_id,
      :update_availability,
    )
  end

  private def client_type
    Translation.translate('De-Identified Clients')
  end
end
