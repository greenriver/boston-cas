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
      'Shelter Agency notified of approved match and asked to record date client housed'
    end

    def should_expire?
      true
    end
    
  end
end
