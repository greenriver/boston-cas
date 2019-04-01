module MatchPrioritization
  class AssessmentScoreLengthHomelessTieBreaker < Base
    def self.title
      'Assessment Score with LoTH tie breaker'
    end

    def self.prioritization_for_clients(scope)
      scope.where.not(c_t[:assessment_score].eq(nil)).
        order(c_t[:assessment_score].desc).
        order(c_t[:days_homeless].desc)
    end

    def self.column_name
      'assessment_score'
    end
  end
end
