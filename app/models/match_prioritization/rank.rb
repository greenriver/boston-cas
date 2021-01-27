###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class Rank < Base

    def self.title
      'Rank'
    end

    def self.prioritization_for_clients(scope, match_route:)
      tag_id = match_route.tag_id
      scope.
        where(Arel.sql("tags ->> '#{tag_id}' IS NOT NULL")).
        order(Arel.sql("tags ->>'#{tag_id}' ASC NULLS LAST"))
    end

    def self.client_prioritization_value_method
      'rank_for_tag'
    end

    def requires_tag?
      true
    end
  end
end
