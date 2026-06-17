###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Thirteen
  class ThirteenMatchAcknowledgementSsp < ::Notifications::Base
    def self.contact_types_for_notification
      [:ssp_contacts]
    end

    def decision
      match.thirteen_match_acknowledgement_decision
    end

    def event_label
      "#{Translation.translate('Stabilization Service Providers Thirteen')} notified of match."
    end
  end
end
