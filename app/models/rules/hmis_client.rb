###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::HmisClient < Rule
  def description
    'Matches clients who come from HMIS via the warehouse.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    if requirement.positive
      scope.where(id: ProjectClient.from_hmis.select(:client_id))
    else
      scope.where(id: ProjectClient.from_non_hmis.select(:client_id))
    end
  end
end
