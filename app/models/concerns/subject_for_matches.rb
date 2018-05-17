module SubjectForMatches
  extend ActiveSupport::Concern

  class_methods do
    def matching_requirements(requirements)
      requirements.reduce(self) do |scope, requirement|
        requirement.clients_that_fit(scope)
      end
    end

    def matchable
      if column_names.include? :matchability
        where(arel_table[:matchability].gt(0))
      else
        all
      end
    end

    def matching_co_candidate(co_candidate)
      matching_requirements(co_candidate.requirements_with_inherited).
        not_rejected_for(co_candidate)
    end

    def not_rejected_for(co_candidate)
      where.not(id: RejectedMatch.select(:client_id).where(opportunity_id: co_candidate))
    end

    # def max_candidate_matches
    #   1
    # end
  end

  included do
    has_many :client_opportunity_matches
    has_many :candidate_matches, -> {where(selected: false, closed: false)}, class_name: "ClientOpportunityMatch"
    has_many :rejected_matches

    def matching_co_candidates_for_max(co_candidates)
      @_matching_co_candidates_for_max ||= co_candidates.matching_co_candidate(self).limit(matches_left_to_max)
    end

    def matching_co_candidates(co_candidates)
      @_matching_co_candidates ||= co_candidates.matching_co_candidate(self)
    end

    def matches_left_to_max
      left = self.class.max_candidate_matches - candidate_matches.size
      left > 0 ? left : 0
    end
  end
end
