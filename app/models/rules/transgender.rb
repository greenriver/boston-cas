###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::Transgender < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:gender_id.to_s)
      gender_arel = Gender.arel_table
      transgender = Gender.where(gender_arel[:text].matches('Trans%')).distinct.pluck(:numeric)
      if requirement.positive
        scope.where(gender_id: transgender)
      else
        scope.where.not(gender_id: transgender)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.gender_id missing. Cannot check clients against #{self.class}.")
    end
  end
end
