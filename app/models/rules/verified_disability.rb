###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::VerifiedDisability < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:disability_verified_on.to_s)
      if requirement.positive
        scope.where.not(disability_verified_on: nil)
      else
        scope.where(disability_verified_on: nil)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.disability_verified_on missing. Cannot check clients against #{self.class}.")
    end
  end
end
