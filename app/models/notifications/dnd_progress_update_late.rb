module Notifications
  class DndProgressUpdateLate < Base
    
    attr_accessor :matches, :should_send
    def self.create_for_matches! matches
      contacts = Set.new
      matches.each do |match|
        contacts += match.dnd_staff_contacts.pluck(:id)
      end
      binding.pry
      contacts.each do |contact_id|
        matches_for_contact = matches.select do |m| 
          m.dnd_staff_contacts.pluck(:contact_id).include?(contact_id)
        end
        contact = Contact.find(contact_id)
        # see if you can skip an after_create call and create these without it
        matches.each do |match|
          should_send = match == matches.last
          create! match: match, recipient: contact, matches: matches, should_send: should_send
          record_delivery_event! unless should_send
          # Where is record_delivery_event! defined?
        end
      end
    end

    def event_label
      "Progress update late, DND notified"
    end
    
    def deliver
      NotificationsMailer.send(notification.notification_type, notification, matches).deliver
      notification.record_delivery_event!
      # DeliverJob.perform_later(self, self.matches) if should_send
    end
    
    class DeliverJob < ActiveJob::Base
      def perform(notification, matches)
        NotificationsMailer.send(notification.notification_type, notification, matches).deliver
        notification.record_delivery_event!
      end
    end
    private_constant :DeliverJob
    
  end
end
