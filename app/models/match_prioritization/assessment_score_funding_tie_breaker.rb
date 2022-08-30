###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# Due to requirements changes, although this prioritization scheme is named AssessmentScoreFundingTieBreaker
# it uses a generic tie breaker date field.
module MatchPrioritization
  class AssessmentScoreFundingTieBreaker < Base
    def self.title
      'Assessment Score with Tie Breaker Date'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.where.not(c_t[:assessment_score].eq(nil)).
        order(c_t[:assessment_score].desc).
        order(c_t[:tie_breaker_date].asc).
        order(c_t[:tie_breaker].asc)
    end

    def self.client_prioritization_summary_method
      'assessment_score'
    end

    def important_days_homeless_calculations
      calculations = [
        :hmis_days_homeless_last_three_years,
        :days_homeless_in_last_three_years,
      ]
      days_homeless_labels.select { |k, _| k.in?(calculations) }
    end
  end
end
