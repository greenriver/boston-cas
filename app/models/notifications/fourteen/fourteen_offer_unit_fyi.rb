###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Fourteen
  class FourteenOfferUnitFyi < ::Notifications::Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts, :housing_subsidy_admin_contacts, :ssp_contacts, :dnd_staff_contacts]
    end

    def decision
      match.fourteen_offer_unit_decision
    end

    def event_label
      'Match contacts notified that unit offer is underway.'
    end
  end
end
