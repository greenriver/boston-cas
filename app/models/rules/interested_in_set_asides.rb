###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::InterestedInSetAsides < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:interested_in_set_asides.to_s)
      scope.where(interested_in_set_asides: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.interested_in_set_asides missing. Cannot check clients against #{self.class}.")
    end
  end
end