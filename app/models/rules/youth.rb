###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::Youth < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:is_currently_youth.to_s)
      eighteen_years_ago = Date.current - 18.years
      twenty_five_years_ago = Date.current - 25.years
      if requirement.positive
        scope.where(
          c_t[:date_of_birth].between(twenty_five_years_ago..eighteen_years_ago).
          or(c_t[:is_currently_youth].eq(true))
        )
      else
        scope.where(
          c_t[:is_currently_youth].eq(false).
          and(
            c_t[:date_of_birth].not_between(twenty_five_years_ago..eighteen_years_ago).
            or(c_t[:date_of_birth].eq(nil))
          )
        )
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.health_prioritized missing. Cannot check clients against #{self.class}.")
    end
  end
end
