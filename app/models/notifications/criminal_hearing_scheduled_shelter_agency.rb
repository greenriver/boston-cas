module Notifications
  class CriminalHearingScheduledShelterAgency < Base
    
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_('Shelter Agency')} sent notice of criminal background hearing date."
    end

    def should_expire?
      true
    end
    
  end
end
