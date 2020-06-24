###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::Female < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:gender_id.to_s)
      female = Gender.where(numeric: [0,2]).pluck(:numeric)
      if requirement.positive
        scope.where(gender_id: female)
      else
        scope.where.not(gender_id: female)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.gender_id missing. Cannot check clients against #{self.class}.")
    end
  end
end
