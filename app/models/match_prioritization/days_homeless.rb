###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchPrioritization
  class DaysHomeless < Base
    def self.title
      'Cumulative days homeless'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.order(c_t[:days_homeless].desc)
    end

    def self.client_prioritization_summary_method
      'days_homeless'
    end

    def self.supporting_column_names
      [
        :days_homeless,
      ]
    end
  end
end
