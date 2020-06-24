###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class RecordClientHousedDateShelterAgency < Base

    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.record_client_housed_date_shelter_agency_decision
    end

    def event_label
      "#{_('Shelter Agency')} notified of approved match and asked to record date client housed"
    end

  end
end
