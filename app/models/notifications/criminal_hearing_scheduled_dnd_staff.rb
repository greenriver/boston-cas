module Notifications
  class CriminalHearingScheduledDndStaff < Base
    
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      'DND sent notice of criminal background hearing date.'
    end

    def should_expire?
      false
    end
    
  end
end
