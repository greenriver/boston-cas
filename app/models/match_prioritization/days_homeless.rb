module MatchPrioritization
  class DaysHomeless < Base

    def self.title
      'Cumulative days homeless'
    end

    def self.slug
      'cumulative-homeless-days'
    end

    def self.column_name
      'days_homeless'
    end
  end
end