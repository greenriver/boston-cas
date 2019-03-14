module MatchPrioritization
  class VispdatPriorityScore < Base
    
    def self.title
      'VI-SPDAT Priority Score'
    end

    def self.prioritization_for_clients(scope)
      scope.where.not(c_t[:vispdat_priority_score].eq(nil)).
          order(c_t[:vispdat_priority_score].desc)
    end

    def self.column_name
      'vispdat_priority_score'
    end
  end
end
