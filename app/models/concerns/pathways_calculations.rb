###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module PathwaysCalculations
  extend ActiveSupport::Concern

  included do
    def calculated_score
      return 0 if ssvf_eligible
      return 0 if !domestic_violence && (days_homeless_in_the_last_three_years.blank? || days_homeless_in_the_last_three_years < 30)
      return 65 if pending_subsidized_housing_placement

      score = 0
      score += 25 if (non_hmis_client.date_of_birth.present? && non_hmis_client.age <= 24) || non_hmis_client.is_currently_youth
      score += if domestic_violence
        15
      else
        case days_homeless_in_the_last_three_years
        when (30..60)
          1
        when (61..90)
          2
        when (91..120)
          3
        when (121..150)
          4
        when (151..180)
          5
        when (181..210)
          6
        when (211..240)
          7
        when (241..269)
          8
        when (270..Float::INFINITY)
          15
        else
           0
        end
      end
      score += 5 if documented_disability
      score += 1 if evicted
      score += 1 if income_maximization_assistance_requested

      score = 1 if score.zero?
      score
    end
  end
end
