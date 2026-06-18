###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchDecisions
  module DefaultShelterAgencyDeclineReasons
    extend ActiveSupport::Concern

    def step_decline_reasons(_contact)
      [
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
