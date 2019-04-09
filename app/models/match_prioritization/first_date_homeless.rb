module MatchPrioritization
  class FirstDateHomeless < Base

    def self.title
      'First date homeless'
    end

    def self.prioritization_for_clients(scope, match_route:)
      scope.order(c_t[:calculated_first_homeless_night].asc)
    end

    def self.client_prioritization_value_method
      'calculated_first_homeless_night'
    end
  end
end