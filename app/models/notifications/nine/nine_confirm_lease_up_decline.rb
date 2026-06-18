###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Nine
  class NineConfirmLeaseUpDecline < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.nine_confirm_lease_up_decline_decision
    end

    def event_label
      "#{Translation.translate('DND')} notified of #{Translation.translate('Housing Subsidy Administrator Nine')} decline. Confirmation pending."
    end
  end
end
