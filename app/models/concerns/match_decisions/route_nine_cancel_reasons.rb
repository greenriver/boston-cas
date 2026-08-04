###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchDecisions
  module RouteNineCancelReasons
    extend ActiveSupport::Concern

    def step_cancel_reasons
      [
        'Match expired',
        'Vacancy should not have been entered',
        'Client received another housing opportunity',
        'Client no longer eligible for match',
        'Client deceased',
        'Incarcerated',
        'Vacancy filled by other client',
        'Client has declined match',
        'Client has disengaged',
        'Client has disappeared',
        'Client needs higher level of care',
        'Unable to reach client after multiple attempts',
        'Other',
      ]
    end
  end
end
