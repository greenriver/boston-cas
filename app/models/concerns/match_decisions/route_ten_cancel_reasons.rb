###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchDecisions
  module RouteTenCancelReasons
    extend ActiveSupport::Concern

    def step_cancel_reasons
      [
        'Client needs higher level of care',
        'Unable to reach client after multiple attempts',
        'Incarcerated',
        'Match expired',
        'Client has declined match',
        'Client has disengaged',
        'Client has disappeared',
        'Vacancy should not have been entered',
        'Client received another housing opportunity',
        'Client no longer eligible for match',
        'Client deceased',
        'Vacancy filled by other client',
        'Other',
      ]
    end
  end
end
