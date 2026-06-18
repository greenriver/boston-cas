###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class ConfirmShelterAgencyDeclineDndStaff < Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def decision
      match.confirm_shelter_agency_decline_dnd_staff_decision
    end

    def event_label
      "#{Translation.translate('DND')} notified of #{Translation.translate('Shelter Agency')} decline.  Confirmation pending."
    end
  end
end
