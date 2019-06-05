###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchPrioritization
  class DaysHomelessLastThreeYearsRandomTieBreaker < Base

    def self.title
      'Days homeless in the last three years with random tie-breaker'
    end

    def self.prioritization_for_clients(scope, match_route:)
      scope.order(Arel.sql(c_t[:days_homeless_in_last_three_years].desc.to_sql + ' NULLS LAST')).
          order(c_t[:tie_breaker].asc)
    end

    def self.client_prioritization_value_method
      'days_homeless_in_last_three_years'
    end
  end
end
