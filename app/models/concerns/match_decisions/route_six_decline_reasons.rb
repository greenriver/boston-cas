###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module RouteSixDeclineReasons
    extend ActiveSupport::Concern

    def step_decline_reasons(_contact)
      [
        'Does not agree to services',
        'Does not want housing at this time',
        'Incarcerated',
        'Client has disengaged',
        'Client has disappeared',
        'Client has another housing option',
        'Client deceased',
        'Other',
        'Health and Safety',
        'Client receiving navigation services',
      ]
    end
  end
end
