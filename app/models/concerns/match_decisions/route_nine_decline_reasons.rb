###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
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
