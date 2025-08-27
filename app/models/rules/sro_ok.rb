###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::SroOk < Rule
  def description
    'Matches clients who have indicated they are OK with SRO housing as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.sro_ok missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:sro_ok.to_s)

    scope.where(sro_ok: requirement.positive)
  end
end
