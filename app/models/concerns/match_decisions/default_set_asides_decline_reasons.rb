###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module DefaultSetAsidesDeclineReasons
    extend ActiveSupport::Concern

    def step_decline_reasons(_contact)
      [
        'Client received another housing opportunity',
        'Client no longer eligible for match',
        'Client deceased',
        'Incarcerated',
        'Vacancy filled by other client',
        'Client has declined match',
        'Client has disengaged',
        'Household could not be located',
        'CORI',
        'Unwilling to live in that neighborhood',
        'Unwilling to live in SRO',
        'Health and Safety',
        'Other',
      ]
    end

    def step_cancel_reasons
      [
        'Match expired',
        'Vacancy should not have been entered',
        'Other',
      ]
    end
  end
end
