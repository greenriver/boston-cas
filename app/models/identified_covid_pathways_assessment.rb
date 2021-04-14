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

  def default?
    false
  end

  def assessment_params(params)
    params.require(:identified_covid_pathways_assessment).permit(
      [
        :entry_date,
        :phone_number,
        :email_addresses,
        :shelter_name,
        :case_manager_contact_info,
        :mailing_address,
        :day_locations,
        :night_locations,
        :other_contact,
        :household_size,
        :pending_subsidized_housing_placement,
        :pending_housing_placement_type_other,
        :income_total_annual,
        :income_maximization_assistance_requested,
        :maximum_possible_monthly_rent,
        :possible_housing_situation_other,
        :rrh_desired,
        :no_rrh_desired_reason_other,
        :dv_rrh_aggregate,
        :rrh_th_desired,
        :sro_ok,
        :required_number_of_bedrooms,
        :requires_wheelchair_accessibility,
        :requires_elevator_access,
        :accessibility_other,
        :disabled_housing,
        :documented_disability,
        :health_prioritized,
        :medical_care_last_six_months,
        :intensive_needs_other,
        :days_homeless_in_the_last_three_years,
        :additional_homeless_nights,
        :notes,
        provider_agency_preference: [],
        neighborhood_interests: [],
        affordable_housing: [],
        service_need_indicators: [],
        intensive_needs: [],
        background_check_issues: [],
      ],
    )
  end
end
