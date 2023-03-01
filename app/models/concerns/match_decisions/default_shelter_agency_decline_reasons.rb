###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module DefaultShelterAgencyDeclineReasons
    extend ActiveSupport::Concern

    def step_decline_reasons(_contact)
      @step_decline_reasons ||= [
        'Client has another housing option',
        'Does not agree to services',
        'Unwilling to live in that neighborhood',
        'Unwilling to live in SRO',
        'Does not want housing at this time',
        'Unsafe environment for this person',
        'Client refused unit (non-SRO)',
        'Client refused voucher',
        'Other',
      ]
    end
  end
end
