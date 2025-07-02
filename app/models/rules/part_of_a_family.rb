###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::PartOfAFamily < Rule
  def description
    'Matches clients who indicated on an assessment that there are more people in their household than just themselves, or who are pregnant.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.family_member missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:family_member.to_s)

    scope.where(family_member: requirement.positive)
  end
end
