###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::Wheelchair < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:requires_wheelchair_accessibility.to_s)
      scope.where(requires_wheelchair_accessibility: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.requires_wheelchair_accessibility missing. Cannot check clients against #{self.class}.")
    end
  end
end
