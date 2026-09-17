###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Fourteen
  class FourteenConfirmMatchSuccessDndStaff < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.fourteen_confirm_match_success_decision
    end

    def event_label
      "#{Translation.translate('CoC Fourteen')} notified to confirm match success."
    end
  end
end
