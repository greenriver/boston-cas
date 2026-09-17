###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Fourteen
  class FourteenOfferUnitHsp < ::Notifications::Base
    def self.contact_types_for_notification
      [:hsp_contacts]
    end

    def decision
      match.fourteen_offer_unit_decision
    end

    def event_label
      "#{Translation.translate('Housing Search Provider Fourteen')} notified to offer a unit or confirm the client is approved for a unit."
    end
  end
end
