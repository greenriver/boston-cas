module MatchPrioritization
  class AssessmentScore < Base

    def self.title
      'Assessment Score'
    end

    def self.prioritization_for_clients(scope)
      scope.where.not(c_t[:assessment_score].eq(nil)).
          order(c_t[:assessment_score].desc).
          order(c_t[:rrh_assessment_collected_at].desc)
    end

    def self.column_name
      'assessment_score'
    end
  end
end