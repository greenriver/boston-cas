###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class OnBehalfOf < Base
    # Custom create_for_match! that accepts contact_type as parameter
    def self.contact_types_for_notification
      [] # Not applicable - contact_type is passed as parameter to create_for_match!
    end

    def self.create_for_match!(match, contact_type, decision_id: nil)
      match.send(contact_type).each do |contact|
        next if contact.user.blank? || !contact.user.active?

        create!(match: match, recipient: contact, decision_id_for_delivery: decision_id)
      end
    end

    def event_label
      "Contact notified, action taken by #{Translation.translate('DND')}"
    end
  end
end
