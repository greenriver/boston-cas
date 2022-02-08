###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::HmisClient < Rule
  def clients_that_fit(scope, requirement, opportunity)
    if requirement.positive
      scope.where(id: ProjectClient.from_hmis.select(:client_id))
    else
      scope.where(id: ProjectClient.from_non_hmis.select(:client_id))
    end
  end
end
