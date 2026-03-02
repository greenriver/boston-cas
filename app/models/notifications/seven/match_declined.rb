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

    def self.create_for_match! match
      contacts = match.contacts - match.dnd_staff_contacts

      contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end
  end
end
