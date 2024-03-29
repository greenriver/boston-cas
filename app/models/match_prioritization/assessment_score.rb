###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class AssessmentScore < Base
    def self.title
      'Assessment Score'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.where.not(c_t[:assessment_score].eq(nil)).
        order(c_t[:assessment_score].desc).
        order(c_t[:rrh_assessment_collected_at].desc)
    end

    def self.client_prioritization_summary_method
      'assessment_score'
    end

    def self.supporting_column_names
      [
        :assessment_score,
      ]
    end
  end
end
