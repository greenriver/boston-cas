###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
