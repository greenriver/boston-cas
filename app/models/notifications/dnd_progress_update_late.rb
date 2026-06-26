###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class DndProgressUpdateLate < Base
    attr_accessor :matches, :should_send

    # Custom create_for_match! that accepts specific contact_id instead of iterating
    def self.contact_types_for_notification
      [] # Not applicable - custom parameters required (match_id, contact_id)
    end

    # Don't deliver after create, we'll handle this in batches
    def deliver
    end

    def self.create_for_match! match_id:, contact_id:
      contact = Contact.find(contact_id)
      return if contact.notification_recipient?

      create! client_opportunity_match_id: match_id, recipient_id: contact_id
    end

    def event_label
      "Progress update late, #{Translation.translate('DND')} notified"
    end
  end
end
