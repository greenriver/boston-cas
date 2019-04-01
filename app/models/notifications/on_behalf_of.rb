module Notifications
  class OnBehalfOf < Base
    def self.create_for_match!(match, contact_type)
      match.send(contact_type).each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "Contact notified, action taken by #{_('DND')}"
    end
  end
end
