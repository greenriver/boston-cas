###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
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
      chronic = Arel.sql(c_t[:chronic_homeless].desc.to_sql + ' NULLS LAST') # chronic prioritized over non-chronic
      entry_date = Arel.sql(c_t[:entry_date].asc.to_sql + ' NULLS LAST') # older prioritized over newer
      vispdat_score = Arel.sql(c_t[:vispdat_score].desc.to_sql + ' NULLS LAST') # higher prioritized over lover

      scope.order(match_group, chronic, entry_date, vispdat_score)
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
