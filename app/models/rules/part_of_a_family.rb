###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::PartOfAFamily < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:family_member.to_s)
      scope.where(family_member: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.family_member missing. Cannot check clients against #{self.class}.")
    end
  end
end
