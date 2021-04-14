###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class IdentifiedPathwaysAssessment < IdentifiedClientAssessment
  include PathwaysCalculations

  def title
    'Pathways'
  end

  def default?
    false
  end

  def assessment_params(params)
    params.require(:identified_pathways_assessment).permit(
      [
        :entry_date,
        :domestic_violence,
        :days_homeless_in_the_last_three_years,
        :veteran,
        :pending_subsidized_housing_placement,
        :income_total_annual,
        :sro_ok,
        :required_number_of_bedrooms,
        :requires_wheelchair_accessibility,
        :requires_elevator_access,
        :other_accessibility,
        :disabled_housing,
        :interested_in_set_asides,
        :ssvf_eligible,
        :rrh_desired,
        :dv_rrh_aggregate,
        :rrh_th_desired,
        :documented_disability,
        :evicted,
        :income_maximization_assistance_requested,
        neighborhood_interests: [],
      ],
    )
  end
end
