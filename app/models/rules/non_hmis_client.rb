###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::NonHmisClient < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if requirement.positive
      scope.where(id: ProjectClient.from_non_hmis.select(:client_id))
    else
      scope.where(id: ProjectClient.from_hmis.select(:client_id))
    end
  end
end
