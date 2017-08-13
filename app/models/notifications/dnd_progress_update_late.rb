module Notifications
  class DndProgressUpdateLate < Base
    attr_accessor :matches, :should_send
    
    def self.create_for_matches! matches
      contacts = Set.new
      matches.each do |match|
        contacts += match.dnd_staff_contacts.pluck(:id)
      end
      contacts.each do |contact_id|
        matches_for_contact = matches.select do |m|
          m.dnd_staff_contacts.pluck(:contact_id).include?(contact_id)
        end
        contact = Contact.find(contact_id)
        matches_for_contact.each do |match|
          should_send = (match == matches_for_contact.last)
          notification = create! match: match, recipient: contact, matches: matches_for_contact, should_send: should_send
          notification.record_delivery_event! unless should_send
        end
      end
    end

    def event_label
      "Progress update late, DND notified"
    end
    
    def deliver
      if should_send  
        NotificationsMailer.send(:dnd_progress_update_late, self, recipient, matches).deliver_now
        record_delivery_event!
      end
    end
  end
end
