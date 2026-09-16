###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Fourteen
  class FourteenOfferUnitDecline < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.fourteen_offer_unit_decline_decision
    end

    def event_label
      "#{Translation.translate('CoC Fourteen')} notified of #{Translation.translate('Housing Search Provider Fourteen')} decline."
    end
  end
end
