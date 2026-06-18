###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Eleven
  class ConfirmMatchSuccessDndStaff < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.eleven_confirm_match_success_dnd_staff_decision
    end

    def event_label
      "#{Translation.translate('CoC Eleven')} Staff notified of successful match and asked to give final confirmation."
    end
  end
end
