###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module MatchDecisions
  module RouteThreeDeclineReasons
    extend ActiveSupport::Concern

    def decline_reasons_not_other_requiring_explanation(contact = nil)
      step_decline_reasons(contact).reject { |reason| reason == 'Other' }
    end
  end
end
