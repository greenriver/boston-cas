###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Thirteen
  class ThirteenHearingScheduledDndStaff < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.thirteen_hearing_scheduled_decision
    end

    def event_label
      "#{Translation.translate('CoC Thirteen')} notified of pending #{Translation.translate('CORI hearing')} review."
    end
  end
end
