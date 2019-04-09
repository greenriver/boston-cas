module MatchPrioritization
  class DaysHomeless < Base

    def self.title
      'Cumulative days homeless'
    end

    def self.prioritization_for_clients(scope, match_route:)
      scope.order(c_t[:days_homeless].desc)
    end

    def self.client_prioritization_value_method
      'days_homeless'
    end
  end
end