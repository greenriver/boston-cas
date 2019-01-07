module MatchPrioritization
  class DaysHomelessLastThreeYears < Base
    
    def self.title
      'Days homeless in the last three years'
    end

    def self.slug
      'homeless-days-last-three-years'
    end

    def self.column_name
      'days_homeless_in_last_three_years'
    end
  end
end
