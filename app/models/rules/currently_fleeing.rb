###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::CurrentlyFleeing < Rule
  def clients_that_fit(scope, requirement, _opportunity)
    column = :currently_fleeing
    column_2 = :dv_date
    raise RuleDatabaseStructureMissing.new("clients.#{column} or clients.#{column_2} missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(column.to_s) && Client.column_names.include?(column_2.to_s)

    c_t = Client.arel_table
    if requirement.positive
      scope.where(
        c_t[column].eq(requirement.positive).
        and(c_t[column_2].gteq(3.months.ago.to_date)),
      )
    else
      scope.where(column => false).
        or(scope.where(column_2 => nil)).
        or(scope.where(c_t[column_2].lt(3.months.ago.to_date)))
    end
  end
end
