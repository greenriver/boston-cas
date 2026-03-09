###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Ten
  class TenConfirmMatchSuccessDndStaff < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.ten_confirm_match_success_dnd_staff_decision
    end

    def event_label
      "#{Translation.translate('DND')} Staff notified of successful match and asked to give final confirmation."
    end
  end
end
