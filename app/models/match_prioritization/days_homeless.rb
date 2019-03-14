module MatchPrioritization
  class DaysHomeless < Base

    def self.title
      'Cumulative days homeless'
    end

    def self.prioritization_for_clients(scope)
      scope.order(c_t[:days_homeless].desc)
    end

    def self.column_name
      'days_homeless'
    end
  end
end