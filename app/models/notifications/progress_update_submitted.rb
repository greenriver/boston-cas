module Notifications
  class ProgressUpdateSubmitted < Base
    
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "Progress update submitted, #{_('DND')} notified"
    end
  end
end
