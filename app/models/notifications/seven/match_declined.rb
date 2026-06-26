###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Seven
  class MatchDeclined < Notifications::MatchDeclined
    def self.contact_types_for_notification
      # DND will receive confirmation step, so they don't need the notification
      []
    end

    def self.create_for_match!(match, decision_id: nil)
      contacts = match.contacts - match.dnd_staff_contacts

      contacts.each do |contact|
        next if contact.notification_recipient?

        create!(match: match, recipient: contact, decision_id_for_delivery: decision_id)
      end
    end
  end
end
