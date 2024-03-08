###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
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
