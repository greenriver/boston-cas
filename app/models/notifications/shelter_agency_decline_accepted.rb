###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class ShelterAgencyDeclineAccepted < Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def decision
      match.confirm_shelter_agency_decline_dnd_staff_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency')} notified of #{Translation.translate('DND')} acceptance of #{Translation.translate('Shelter Agency')} decline"
    end
  end
end
