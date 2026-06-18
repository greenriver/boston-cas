###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Thirteen
  class ThirteenHearingScheduledSsp < ::Notifications::Base
    def self.contact_types_for_notification
      [:ssp_contacts]
    end

    def decision
      match.thirteen_hearing_scheduled_decision
    end

    def event_label
      "#{Translation.translate('Stabilization Service Providers Thirteen')} notified to schedule CORI review."
    end
  end
end
