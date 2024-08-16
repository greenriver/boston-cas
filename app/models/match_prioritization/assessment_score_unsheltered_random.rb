###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class AssessmentScoreUnshelteredRandom < Base
    def self.title
      'Total Unsheltered nights, random tie breaker'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.where.not(c_t[:total_homeless_nights_unsheltered].eq(nil)).
        order(c_t[:total_homeless_nights_unsheltered].desc).
        order(c_t[:tie_breaker].asc)
    end

    def self.client_prioritization_summary_method
      'total_homeless_nights_unsheltered'
    end

    def self.supporting_column_names
      [
        :total_homeless_nights_unsheltered,
      ]
    end
  end
end
