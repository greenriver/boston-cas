module MatchPrioritization
  class DaysHomelessLastThreeYears < Base

    def self.title
      'Days homeless in the last three years'
    end

    def self.prioritization_for_clients(scope, match_route:)
      scope.order(c_t[:days_homeless_in_last_three_years].desc)
    end

    def self.client_priortization_value_method
      'days_homeless_in_last_three_years'
    end
  end
end
