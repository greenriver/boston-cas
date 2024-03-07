###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class MatchGroup < Base
    def self.title
      'Match Group'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      # NOTE: after Rails 6.1 upgrade, these could be written c_t[:veteran].desc.nulls_last
      match_group = Arel.sql(c_t[:match_group].asc.to_sql + ' NULLS LAST') # 1, 2, 3
      veteran = Arel.sql(c_t[:veteran].desc.to_sql + ' NULLS LAST') # veteran prioritized over non-veteran
      chronic = Arel.sql(c_t[:chronic_homeless].desc.to_sql + ' NULLS LAST') # chronic prioritized over non-chronic
      days_homeless = Arel.sql(c_t[:days_homeless].desc.to_sql + ' NULLS LAST') # longer homeless period prioritized over shorter
      # entry date and vispdat score removed 10/8 in favor of cumulative LOT homeless
      # entry_date = Arel.sql(c_t[:entry_date].asc.to_sql + ' NULLS LAST') # older prioritized over newer
      # vispdat_score = Arel.sql(c_t[:vispdat_score].desc.to_sql + ' NULLS LAST') # higher prioritized over lower

      scope.order(match_group, veteran, chronic, days_homeless)
    end

    def self.supporting_column_names
      [
        :match_group,
        :encampment_decomissioned,
        :veteran,
        :chronic_homeless,
      ]
    end

    def self.supporting_data_columns
      {
        'Match Group' => ->(client) { client.match_group },
        'Encampment Decomissioned' => ->(client) { client.encampment_decomissioned? },
        'Veteran' => ->(client) { client.veteran? },
        'Chronic' => ->(client) { client.chronic_homeless? },
      }
    end
  end
end
