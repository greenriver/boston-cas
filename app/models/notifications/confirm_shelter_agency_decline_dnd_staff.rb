module Notifications
  class ConfirmShelterAgencyDeclineDndStaff < Base
    
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end
    
    def decision
      match.confirm_shelter_agency_decline_dnd_staff_decision
    end

    def event_label
      'DND notified of shelter agency decline.  Confirmation pending.'
    end

    def should_expire?
      true
    end
    
  end
end
