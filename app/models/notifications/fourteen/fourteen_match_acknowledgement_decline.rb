###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Fourteen
  class FourteenMatchAcknowledgementDecline < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.fourteen_match_acknowledgement_decline_decision
    end

    def event_label
      "#{Translation.translate('CoC Fourteen')} notified of #{Translation.translate('Shelter Agency Fourteen')} decline."
    end
  end
end
