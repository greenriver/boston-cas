###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class DaysHomelessPopulations < Base
    def self.title
      'Veteran, Adult and Child, Youth, Cumulative days homeless'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.order(c_t[:veteran].desc, c_t[:family_member].desc, c_t[:is_currently_youth].desc, Arel.sql("case when date_part('year', age(\"clients\".\"date_of_birth\")) BETWEEN 18 and 24 then 1 else 0 end desc"), c_t[:days_homeless].desc)
    end

    def self.client_prioritization_value_method
      'days_homeless_populations'
    end
  end
end
