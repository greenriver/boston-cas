module Notifications
  class CriminalHearingScheduledDndStaff < Base
    
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_('DND')} #{_('sent notice of criminal background hearing date.')}"
    end

  end
end
