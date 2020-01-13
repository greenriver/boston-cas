###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Notifications
  class NoteSent < Base
    attr_accessor :note

    def self.create_for_match! match_id:, contact_id:, note:, include_content: true
      create! client_opportunity_match_id: match_id, recipient_id: contact_id, note: note, include_content: include_content
    end

    # override deliver so we can pass along the note
    def deliver
      NotificationsMailer.with(notification: self, note: note).note_sent.deliver_later
      record_delivery_event!
    end

    def event_label
      "Note sent"
    end
  end
end
