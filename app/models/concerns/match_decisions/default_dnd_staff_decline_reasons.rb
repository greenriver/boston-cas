###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module DefaultDndStaffDeclineReasons
    extend ActiveSupport::Concern

    def step_decline_reasons(_contact)
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
