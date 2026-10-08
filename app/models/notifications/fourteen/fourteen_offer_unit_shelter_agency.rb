###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Fourteen
  class FourteenOfferUnitShelterAgency < ::Notifications::Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def decision
      match.fourteen_offer_unit_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency Fourteen')} notified to confirm the unit was offered to the client."
    end
  end
end
