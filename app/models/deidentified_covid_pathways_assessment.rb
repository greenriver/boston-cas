###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class DeidentifiedCovidPathwaysAssessment < DeidentifiedClientAssessment
  include CovidPathwaysCalculations

  def title
    'COVID Pathways'
  end

  def default?
    false
  end


  def assessment_params(params)
    params.require(:deidentified_covid_pathways_assessment).permit(
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
