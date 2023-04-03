###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class DaysHomelessLastThreeYears < Base
    def self.title
      'Days homeless in the last three years'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.order(c_t[:days_homeless_in_last_three_years].desc)
    end

    def self.client_prioritization_summary_method
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
