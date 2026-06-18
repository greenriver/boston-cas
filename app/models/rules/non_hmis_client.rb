###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::NonHmisClient < Rule
  def description
    'Matches clients who were entered directly in CAS as non-HMIS clients.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    if requirement.positive
      scope.where(id: ProjectClient.from_non_hmis.select(:client_id))
    else
      scope.where(id: ProjectClient.from_hmis.select(:client_id))
    end
  end
end
