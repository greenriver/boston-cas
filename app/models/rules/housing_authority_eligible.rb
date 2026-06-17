###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::HousingAuthorityEligible < Rule
  def description
    "Matches clients who are #{Translation.translate('Housing Authority Eligible').downcase}. This is no longer in use."
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.ha_eligible missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:ha_eligible.to_s)

    scope.where(ha_eligible: requirement.positive)
  end
end
