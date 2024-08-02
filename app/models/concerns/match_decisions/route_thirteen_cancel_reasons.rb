###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module RouteThirteenCancelReasons
    extend ActiveSupport::Concern

    def step_cancel_reasons
      [
        'Incarcerated',
        'Institutionalized',
        'In Treatment/Recovery Center',
        'Match expired',
        'Client has disengaged',
        'Client has disappeared',
        'CORI',
        'SORI',
        'Vacancy should not have been entered',
        'Client received another housing opportunity',
        'Client no longer eligible for match',
        'Client deceased',
        'Vacancy filled by other client',
        'Health and Safety',
        'Do not allow other matches for this vacancy',
        'Other',
      ]
    end
  end
end
