###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class MatchGroupDisability < Base
    def self.title
      'Match Group with Disability'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      # NOTE: after Rails 6.1 upgrade, these could be written c_t[:veteran].desc.nulls_last
      match_group = Arel.sql(c_t[:match_group].asc.to_sql + ' NULLS LAST') # 1, 2, 3
      chronic = Arel.sql(c_t[:chronic_homeless].desc.to_sql + ' NULLS LAST') # chronic prioritized over non-chronic
      entry_date = Arel.sql(c_t[:entry_date].asc.to_sql + ' NULLS LAST') # older prioritized over newer
      vispdat_score = Arel.sql(c_t[:vispdat_score].desc.to_sql + ' NULLS LAST') # higher prioritized over lover

      # TODO: check disability_verified_on too?
      has_disability = c_t[:physical_disability].eq(true).or(c_t[:developmental_disability].eq(true))

      scope.where(has_disability).order(match_group, chronic, entry_date, vispdat_score)
    end

    def self.client_prioritization_value_method
      'match_group_with_disability'
    end
  end
end
