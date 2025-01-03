###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module RouteThirteenDeclineReasons
    extend ActiveSupport::Concern

    def step_decline_reasons(_contact)
      [
        'SORI',
        'CORI',
        'Does not agree to services',
        'Immigration status',
        'Unsafe environment for this person',
        'Unwilling to live in that neighborhood',
        'Unwilling to live in SRO',
        'Does not want housing at this time',
        'Falsification of documents',
        'Client has another housing option',
        'Household did not respond after initial acceptance of match',
        'Ineligible for Housing Program', # Additional Text Required
        'Client refused offer',
        'Client refused unit (non-SRO)',
        'Additional screening criteria imposed by third parties', # Additional Text Required
        'Health and Safety',
        'Client refused voucher',
        'Other',
      ]
    end

    def decline_reasons_not_other_requiring_explanation
      [
        'Ineligible for Housing Program',
        'Additional screening criteria imposed by third parties',
      ]
    end
  end
end
