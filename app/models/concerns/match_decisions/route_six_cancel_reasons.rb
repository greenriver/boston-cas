###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchDecisions
  module RouteSixCancelReasons
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
        'Client no longer eligible for match',
        'Client deceased',
      ]
    end
  end
end
