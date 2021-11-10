###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class DaysHomelessLastThreeYearsAssessmentDate < Base
    def self.title
      'Days homeless in the last three years with earliest assessment date tie breaker'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.order(Arel.sql(c_t[:days_homeless_in_last_three_years].desc.to_sql + ' NULLS LAST')).
        order(Arel.sql(c_t[:entry_date].asc.to_sql + ' NULLS LAST')).
        order(c_t[:tie_breaker].asc)
    end

    def self.client_prioritization_value_method
      'days_homeless_in_last_three_years'
    end
  end
end