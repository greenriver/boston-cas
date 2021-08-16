###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class IdentifiedCovidPathwaysAssessment < IdentifiedClientAssessment
  include CovidPathwaysCalculations

  def title
    'COVID Pathways'
  end

  def self.client_table_headers(user)
    columns = [
      'Last Name',
      'First Name',
      'Agency',
    ]
    columns << 'Assessment Score' if user.can_manage_identified_clients?
    columns << 'Assessment Date'
    columns << 'Status'
    columns << 'CAS Client' if user.can_view_some_clients?
    columns << '' if user.can_manage_identified_clients?
    columns
  end

  def self.client_table_row(client, user)
    url_helpers = Rails.application.routes.url_helpers
    view_helper = ActionController::Base.helpers
    current_assessment = client.current_assessment
    row = [
      view_helper.link_to(client.last_name, url_helpers.identified_client_path(id: client.id)),
      view_helper.link_to(client.first_name, url_helpers.identified_client_path(id: client.id)),
      client.agency&.name,
    ]
    score = if current_assessment&.assessment_score&.zero?
      '0 – Ineligible'
    else
      current_assessment&.assessment_score
    end
    assessment_title = view_helper.content_tag(:em, current_assessment&.title)
    assessment_title = view_helper.content_tag(:div, assessment_title, class: 'mt-2')
    assessment_date = view_helper.content_tag(:span, client&.assessed_at&.to_date.to_s)
    assessment_date = view_helper.content_tag(:span) do
      view_helper.concat(assessment_date)
      view_helper.concat(assessment_title)
    end
    client_link = view_helper.link_to(url_helpers.client_path(client.client), class: 'btn btn-secondary btn-sm d-inline-flex align-items-center') do
      view_helper.concat 'View'
      view_helper.concat view_helper.content_tag(:span, nil, class: 'icon-arrow-right2 ml-2')
    end
    delete_link = view_helper.link_to(url_helpers.identified_client_path(client), method: :delete, data: { confirm: 'Would you really like to delete this Non-HMIS client?' }, class: ['btn', 'btn-sm', 'btn-danger']) do
      view_helper.concat(view_helper.content_tag(:span, nil, class: 'icon-cross'))
      view_helper.concat(view_helper.content_tag(:span, 'Delete'))
    end
    row << score if user.can_manage_identified_clients?
    row << assessment_date
    row << if client.available then 'Available' else 'Ineligible' end
    row << client_link if user.can_view_some_clients? && client.client
    row << delete_link if user.can_manage_identified_clients? && ! client.involved_in_match?

    row
  end

  def default?
    false
  end

  def assessment_params(params)
    params.require(:identified_covid_pathways_assessment).permit(
      [
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
        neighborhood_interests: [],
        provider_agency_preference: [],
        affordable_housing: [],
        high_covid_risk: [],
        service_need_indicators: [],
        intensive_needs: [],
        background_check_issues: [],
      ],
    )
  end
end
