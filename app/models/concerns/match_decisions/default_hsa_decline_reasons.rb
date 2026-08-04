###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MatchDecisions
  module DefaultHsaDeclineReasons
    extend ActiveSupport::Concern

    def step_decline_reasons(_contact)
      [
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
