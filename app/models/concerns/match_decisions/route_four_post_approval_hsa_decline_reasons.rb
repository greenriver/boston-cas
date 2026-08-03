###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MatchDecisions
  module RouteFourPostApprovalHsaDeclineReasons
    extend ActiveSupport::Concern

    def step_decline_reasons(_contact)
      [
        'Ineligible for Housing Program',
        'Client has another housing option',
        'Client refused unit (non-SRO)',
        'Client refused voucher',
        'Does not agree to services',
        'Does not want housing at this time',
        'Unsafe environment for this person',
        'Unwilling to live in that neighborhood',
        'Unwilling to live in SRO',
        'Client has disappeared',
        'Client has disengaged',
        'Client deceased',
        'Incarcerated',
        'Other',
      ]
    end
  end
end
