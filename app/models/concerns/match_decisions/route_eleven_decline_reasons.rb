###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module RouteElevenDeclineReasons
    extend ActiveSupport::Concern

    def step_decline_reasons(_contact)
      [
        'Client has another housing option',
        'Client is already receiving navigation services',
        'Health and Safety',
        'Does not agree to services',
        'Does not want housing at this time',
        'Incarcerated',
        'Client has disengaged',
        'Client has disappeared',
        'Client deceased',
        'Other',
      ]
    end
  end
end
