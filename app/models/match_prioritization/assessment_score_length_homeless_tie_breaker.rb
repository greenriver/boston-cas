###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchPrioritization
  class AssessmentScoreLengthHomelessTieBreaker < Base
    def self.title
      'Assessment Score with LoTH tie breaker'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.where.not(c_t[:assessment_score].eq(nil)).
        order(c_t[:assessment_score].desc).
        order(c_t[:days_homeless].desc)
    end

    def self.supporting_column_names
      [
        :assessment_score,
      ]
    end

    def self.client_prioritization_summary_method
      'assessment_score'
    end
  end
end
