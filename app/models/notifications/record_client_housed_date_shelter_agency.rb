###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class RecordClientHousedDateShelterAgency < Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def decision
      match.record_client_housed_date_shelter_agency_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency')} notified of approved match and asked to record date client housed"
    end
  end
end
