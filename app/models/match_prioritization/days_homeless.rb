###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

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
