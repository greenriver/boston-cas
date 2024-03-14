###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class IdentifiedClientsController < NonHmisClientsController
  include HasMatchAccessContext
  before_action :require_can_enter_identified_clients!, except: [:current_assessment_limited]
  before_action :require_match_access_context!, only: [:current_assessment_limited]
  before_action :require_can_manage_identified_clients!, only: [:destroy]

  def create
    @non_hmis_client = client_source.create(clean_params(identified_client_params))
    respond_with(@non_hmis_client, location: new_identified_client_non_hmis_assessment_path(@non_hmis_client))
  end

  def update
    add_shelter_history(clean_params(identified_client_params))
    @non_hmis_client.update(clean_params(identified_client_params))
    if pathways_enabled?
      # mark the client as available if this is a new assessment
      unless params[:assessment_id].present? || identified_client_params[:client_assessments_attributes].blank?
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
    respond_with(@non_hmis_client, location: identified_clients_path)
  end

  def assessment_type
    Config.get(:identified_client_assessment) || 'IdentifiedClientAssessment'
  end

  def clean_params dirty_params
    dirty_params = clean_client_params(dirty_params)

    return dirty_params
  end

  def sort_options
    [
      { title: 'Last Name A-Z', column: 'last_name', direction: 'asc', order: 'LOWER(last_name) ASC', visible: true },
      { title: 'Last Name Z-A', column: 'last_name', direction: 'desc', order: 'LOWER(last_name) DESC', visible: true },
      { title: 'Age', column: 'date_of_birth', direction: 'asc', order: 'date_of_birth ASC', visible: true },
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
    [:agency, :cohort, :family_member, :available]
  end
  helper_method :filter_terms

  private def client_source
    IdentifiedClient.identified.visible_to(current_user)
  end

  private def path_for_non_hmis_client
    identified_client_path(id: @non_hmis_client.id)
  end

  private def identified_client_params
    params.require(:identified_client).permit(
      :agency_id,
      :contact_id,
      :first_name,
      :last_name,
      :middle_name,
      :date_of_birth,
      :ssn,
      :ethnicity,
      :limited_release_on_file,
      :full_release_on_file,
      :available,
      :available_date,
      :available_reason,
      :active_client,
      :eligible_for_matching,
      :set_asides_housing_status,
      :is_currently_youth,
      :ssn_refused,
      :assessment_score,
      :vispdat_score,
      :vispdat_priority_score,
      :shelter_name,
      :warehouse_client_id,
      active_cohort_ids: [],
      gender: [],
      race: [],
      client_assessments_attributes: [
        :id,
        :type,
        :entry_date,
        :assessment_score,
        :vispdat_score,
        :vispdat_priority_score,
        :actively_homeless,
        :days_homeless_in_the_last_three_years,
        :date_days_homeless_verified,
        :who_verified_days_homeless,
        :veteran,
        :veteran_status,
        :rrh_desired,
        :youth_rrh_desired,
        :rrh_assessment_contact_info,
        :income_maximization_assistance_requested,
        :income_total_monthly,
        :pending_subsidized_housing_placement,
        :requires_wheelchair_accessibility,
        :required_number_of_bedrooms,
        :required_minimum_occupancy,
        :requires_elevator_access,
        :family_member,
        :calculated_chronic_homelessness,
        :income_total_annual,
        :disabling_condition,
        :physical_disability,
        :developmental_disability,
        :domestic_violence,
        :interested_in_set_asides,
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
    ).merge(identified: true)
  end

  private def client_type
    Translation.translate('Identified Clients')
  end
end
