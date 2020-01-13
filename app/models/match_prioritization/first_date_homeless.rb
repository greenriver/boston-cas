###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

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