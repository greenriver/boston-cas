###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class AssessmentScore < Base

    def self.title
      'Assessment Score'
    end

    def self.prioritization_for_clients(scope, match_route:)
      scope.where.not(c_t[:assessment_score].eq(nil)).
          order(c_t[:assessment_score].desc).
          order(c_t[:rrh_assessment_collected_at].desc)
    end

    def self.client_prioritization_value_method
      'assessment_score'
    end
  end
end
