module MatchPrioritization
  class FirstDateHomeless < Base

    def self.title
      'First date homeless'
    end

    def self.prioritization_for_clients(scope)
      scope.order(c_t[:calculated_first_homeless_night].asc)
    end

    def self.column_name
      'calculated_first_homeless_night'
    end
  end
end