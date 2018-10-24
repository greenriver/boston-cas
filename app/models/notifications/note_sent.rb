module Notifications
  class NoteSent < Base
    attr_accessor :note

    def self.create_for_match! match_id:, contact_id:, note:
      create! client_opportunity_match_id: match_id, recipient_id: contact_id, note: note
    end

    # override deliver so we can pass along the note
    def deliver
      NotificationsMailer.note_sent(self, note).deliver_later
      record_delivery_event!
    end

    def event_label
      "Note sent"
    end
  end
end
