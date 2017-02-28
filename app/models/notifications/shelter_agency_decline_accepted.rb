module Notifications
  class ShelterAgencyDeclineAccepted < Base
    
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end
    
    def decision
      match.confirm_shelter_agency_decline_dnd_staff_decision
    end

    def event_label
      'Shelter Agency notified of DND acceptance of Shelter Agency decline'
    end
    
  end
end
