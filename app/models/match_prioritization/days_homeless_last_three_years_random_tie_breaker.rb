###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class DaysHomelessLastThreeYearsRandomTieBreaker < Base
    def self.title
      'Days homeless in the last three years with random tie-breaker'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.order(Arel.sql(c_t[:days_homeless_in_last_three_years].desc.to_sql + ' NULLS LAST')).
        order(c_t[:tie_breaker].asc)
    end

    def self.client_prioritization_value_method
      'days_homeless_in_last_three_years'
    end

    def important_days_homeless_calculations
      calculations = [
        :hmis_days_homeless_last_three_years,
        :days_homeless_in_last_three_years,
      ]
      days_homeless_labels.select { |k, _| k.in?(calculations) }
    end
  end
end
