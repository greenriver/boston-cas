###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchPrioritization
  class Rank < Base

    def self.title
      'Rank'
    end

    def self.prioritization_for_clients(scope, match_route:)
      tag_id = match_route.tag_id
      scope.where("tags ->> '#{tag_id}' is not null").order("tags->>'#{tag_id}' asc NULLS LAST")
    end

    def self.client_prioritization_value_method
      'rank_for_tag'
    end

    def requires_tag?
      true
    end
  end
end