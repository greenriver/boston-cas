###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module DefaultSetAsidesDeclineReasons
    extend ActiveSupport::Concern

    def step_decline_reasons(_contact)
      @step_decline_reasons ||= [
        'Client received another housing opportunity',
        'Client no longer eligible for match',
        'Client deceased',
        'Incarcerated',
        'Vacancy filled by other client',
        'Client has declined match',
        'Client has disengaged',
        'Client cannot be located',
        'CORI',
        'Unwilling to live in that neighborhood',
        'Unwilling to live in SRO',
        'Other',
      ]
    end
  end
end
