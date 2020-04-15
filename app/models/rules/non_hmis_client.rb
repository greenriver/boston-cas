###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::NonHmisClient < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if requirement.positive
      scope.joins(:project_client).
        where(
          pc_t[:data_source_id].in(
            Arel.sql(
              DataSource.non_hmis.select(:id).to_sql
            )
          )
        )
    else
      scope.joins(:project_client).
        where(
          pc_t[:data_source_id].in(
            Arel.sql(
              DataSource.hmis.select(:id).to_sql
            )
          )
        )
    end
  end
end
