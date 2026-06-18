###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchDecisions
  module RouteTwelveDeclineReasons
    extend ActiveSupport::Concern

    def step_decline_reasons(_contact)
      [
        'Immigration status',
        'Household did not respond after initial acceptance of match',
        'Ineligible for Housing Program',
        'Client refused offer',
        'Self-resolved',
        'Client needs higher level of care',
        'Unable to reach client after multiple attempts',
        'Other',
      ]
    end
  end
end
