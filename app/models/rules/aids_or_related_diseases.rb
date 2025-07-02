###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::AidsOrRelatedDiseases < Rule
  def description
    'Matches clients who are HIV-positive or HIV/AIDS (HUD).'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.hiv_aids missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:hiv_aids.to_s) && Client.column_names.include?(:hiv_positive.to_s)

    if requirement.positive
      scope.where(c_t[:hiv_aids].eq(true).or(c_t[:hiv_positive].eq(true)))
    else
      scope.where(c_t[:hiv_aids].eq(false).and(c_t[:hiv_positive].eq(false)))
    end
  end
end
