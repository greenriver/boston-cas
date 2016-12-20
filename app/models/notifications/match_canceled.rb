module Notifications
  class MatchCanceled < Base
    
    def self.create_for_match! match
      (match.contacts - match.dnd_staff_contacts).each do |contact|
        create! match: match, recipient: contact
      end
    end
    
    def event_label
      'Contact notified, match canceled'
    end
  end
end
