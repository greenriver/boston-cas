###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class FirstDateHomeless < Base
    def self.title
      'First date homeless'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.order(c_t[:calculated_first_homeless_night].asc)
    end

    def self.client_prioritization_summary_method
      'calculated_first_homeless_night'
    end

    def self.supporting_column_names
      [
        :calculated_first_homeless_night,
      ]
    end
  end
end
