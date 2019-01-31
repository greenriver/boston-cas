module MatchPrioritization
  class VispdatScore < Base

    def self.title
      'VI-SPDAT Score'
    end

    def self.prioritization_for_clients
      where.not(c_t[vispdat_score].eq(nil))
          .order(c_t[:vispdat_score].desc)
    end

    def self.column_name
      'vispdat_score'
    end
  end
end