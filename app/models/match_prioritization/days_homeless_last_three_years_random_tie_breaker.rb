module MatchPrioritization
  class DaysHomelessLastThreeYearsRandomTieBreaker < Base

    def self.title
      'Days homeless in the last three years with random tie-breaker'
    end

    def self.prioritization_for_clients
      order(c_t[:days_homeless_in_last_three_years].desc.to_sql + ' NULLS LAST').
          order(c_t[:tie_breaker].asc)
    end

    def self.column_name
      'days_homeless_in_last_three_years'
    end
  end
end
