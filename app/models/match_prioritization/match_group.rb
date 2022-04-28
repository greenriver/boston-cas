###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class MatchGroup < Base
    def self.title
      'Match Group, Entry Date, VI-SPDAT score'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.order(Arel.sql(c_t[:match_group].asc.to_sql + ' NULLS LAST')).
        order(Arel.sql(c_t[:entry_date].asc.to_sql + ' NULLS LAST')).
        order(Arel.sql(c_t[:vispdat_score].desc.to_sql + ' NULLS LAST'))
    end

    def self.client_prioritization_value_method
      'match_group'
    end
  end
end
