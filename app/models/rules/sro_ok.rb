###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::SroOk < Rule
  def description
    'Matches clients who have indicated they are OK with SRO housing as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.sro_ok missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:sro_ok.to_s)

    scope.where(sro_ok: requirement.positive)
  end
end
