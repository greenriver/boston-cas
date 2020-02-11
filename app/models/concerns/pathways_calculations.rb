###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module PathwaysCalculations
  extend ActiveSupport::Concern

  included do
    before_save :update_assessment_score


    private def update_assessment_score
      self.assessment_score = calculated_score
    end

    def calculated_score
      return nil if ssvf_eligible && veteran_rrh_desired
      return 65 if ssvf_eligible

      score = 0
      score += 25 if non_hmis_client.date_of_birth.present? && non_hmis_client.age <= 24
      score += 15 if domestic_violence
      score += if domestic_violence
        0
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