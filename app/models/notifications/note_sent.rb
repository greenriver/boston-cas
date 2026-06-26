###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class NoteSent < Base
    attr_accessor :note

    # Custom create_for_match! with additional parameters (note, include_content)
    def self.contact_types_for_notification
      [] # Not applicable - custom parameters required (match_id, contact_id, note, include_content)
    end

    def self.create_for_match! match_id:, contact_id:, note:, include_content: true
      contact = Contact.find(contact_id)
      return if contact.user.blank? || !contact.user.active?

      create! client_opportunity_match_id: match_id, recipient_id: contact_id, note: note, include_content: include_content
    end

    # override deliver so we can pass along the note
    def deliver
      NotificationsMailer.note_sent(self, note).deliver_later
      record_delivery_event!
    end

    def event_label
      'Note sent'
    end
  end
end
