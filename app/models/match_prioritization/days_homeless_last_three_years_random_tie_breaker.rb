module MatchPrioritization
  class DaysHomelessLastThreeYearsRandomTieBreaker < Base

    def self.title
      'Days homeless in the last three years with random tie-breaker'
    end

    def self.slug
      'homeless-days-last-three-years-random-tie-breaker'
    end

    def self.column_name
      'days_homeless_in_last_three_years'
    end
  end
end
