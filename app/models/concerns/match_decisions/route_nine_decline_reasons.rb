###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchDecisions
  module RouteNineDeclineReasons
    extend ActiveSupport::Concern

    def step_decline_reasons
      [
        "Client won't be eligible for services",
        "Client won't be eligible for housing type",
        "Client won't be eligible based on funding source",
        'Client has another housing option',
        'Other',
      ]
    end
  end
end
