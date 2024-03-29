###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class VispdatScore < Base
    def self.title
      'VI-SPDAT Score'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.where.not(c_t[:vispdat_score].eq(nil)).
        order(c_t[:vispdat_score].desc)
    end

    def self.client_prioritization_summary_method
      'vispdat_score'
    end

    def self.supporting_column_names
      [
        :vispdat_score,
      ]
    end
  end
end
