###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchDecisions
  module RouteElevenCancelReasons
    extend ActiveSupport::Concern

    def step_cancel_reasons
      [
        'Incarcerated',
        'Match expired',
        'Client has declined match',
        'Client has disengaged',
        'Client has disappeared',
        'Vacancy should not have been entered',
        'Client received another housing opportunity',
        'Client is already receiving navigation services',
        'Client no longer eligible for match',
        'Client deceased',
        'Other',
      ]
    end
  end
end
