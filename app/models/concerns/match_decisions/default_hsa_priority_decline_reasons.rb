###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module DefaultHsaPriorityDeclineReasons
    extend ActiveSupport::Concern

    def step_decline_reasons(_contact)
      @step_decline_reasons ||= [
        'Household could not be located',
        'Ineligible for Housing Program',
        'Client refused offer',
        'Health and Safety',
        'Other',
      ]
    end
  end
end
