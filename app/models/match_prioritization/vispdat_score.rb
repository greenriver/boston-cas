###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class VispdatScore < Base

    def self.title
      'VI-SPDAT Score'
    end

    def self.prioritization_for_clients(scope, match_route:)
      scope.where.not(c_t[:vispdat_score].eq(nil))
          .order(c_t[:vispdat_score].desc)
    end

    def self.client_prioritization_value_method
      'vispdat_score'
    end
  end
end