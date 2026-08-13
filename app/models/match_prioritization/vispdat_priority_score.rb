###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchPrioritization
  class VispdatPriorityScore < Base
    def self.title
      'VI-SPDAT Priority Score'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.where.not(c_t[:vispdat_priority_score].eq(nil)).
        order(c_t[:vispdat_priority_score].desc)
    end

    def self.client_prioritization_summary_method
      'vispdat_priority_score'
    end

    def self.supporting_column_names
      [
        :vispdat_priority_score,
      ]
    end
  end
end
