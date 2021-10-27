###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class AssessmentScoreFundingTieBreaker < Base
    def self.title
      'Assessment Score with Funding Date Tie Breaker'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.where.not(c_t[:assessment_score].eq(nil)).
        order(c_t[:assessment_score].desc).
        order(c_t[:financial_assistance_end_date].asc).
        order(c_t[:tie_breaker].asc)
    end

    def self.client_prioritization_value_method
      'assessment_score'
    end
  end
end
