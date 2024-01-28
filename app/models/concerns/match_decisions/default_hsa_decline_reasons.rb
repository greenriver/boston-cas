###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module DefaultHsaDeclineReasons
    extend ActiveSupport::Concern

    def step_decline_reasons(_contact)
      [
        'Immigration status',
        'Ineligible for Housing Program',
        'Self-resolved',
        'Falsification of documents',
        'Health and Safety',
        'CORI',
        'SORI',
        'Household did not respond after initial acceptance of match',
        'Client refused offer',
        'Additional screening criteria imposed by third parties',
        'Other',
      ]
    end
  end
end
