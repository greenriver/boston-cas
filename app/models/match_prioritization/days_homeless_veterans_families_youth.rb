###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class DaysHomelessVeteransFamiliesYouth < Base
    def self.title
      'Veteran, Adult and Child, Youth, Cumulative days homeless'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      # NOTE: after Rails 6.1 upgrade, these could be written c_t[:veteran].desc.nulls_last
      vets = Arel.sql(c_t[:veteran].desc.to_sql + ' NULLS LAST')
      family = Arel.sql(c_t[:family_member].desc.to_sql + ' NULLS LAST')
      is_youth = Arel.sql(c_t[:is_currently_youth].desc.to_sql + ' NULLS LAST')
      age_youth = Arel.sql("case when date_part('year', age(\"clients\".\"date_of_birth\")) BETWEEN 18 and 24 then 1 else 0 end desc")
      days = Arel.sql(c_t[:days_homeless].desc.to_sql + ' NULLS LAST')
      scope.order(vets, family, is_youth, age_youth, days)
    end

    def self.supporting_column_names
      [
        :veteran,
        :family_member,
        :calculated_is_currently_youth,
        :days_homeless,
      ]
    end

    def self.supporting_data_columns
      {
        'Veteran' => ->(client) { client.veteran? },
        'Adult and Child' => ->(client) { client.family_member? },
        'Youth' => ->(client) { client.is_currently_youth? || client.age&.between?(18, 24) || false },
        'Cumulative days homeless' => ->(client) { client.days_homeless },
      }
    end
  end
end
