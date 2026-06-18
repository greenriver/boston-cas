###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Nine
  class NineConfirmAssignManagerDecline < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.nine_confirm_assign_manager_decline_decision
    end

    def event_label
      "#{Translation.translate('DND')} notified of #{Translation.translate('Stabilization Service Provider Nine')} decline. Confirmation pending."
    end
  end
end
