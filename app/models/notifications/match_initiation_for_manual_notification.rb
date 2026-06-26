###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class MatchInitiationForManualNotification < Notifications::Base
    # Custom create_for_match! with dynamic contact type and conditional logic
    def self.contact_types_for_notification
      [] # Not applicable - uses dynamic contact type from match.match_route.initial_contacts_for_match
    end

    def self.create_for_match!(match, decision_id: nil)
      match.send(match.match_route.initial_contacts_for_match).each do |contact|
        # this notification includes a link to the un-started matches, don't send anything
        # if the user can't access the link
        user = contact.user
        next if user.blank? || !user.active?
        next unless user&.can_see_alternate_matches? || user&.can_see_all_alternate_matches?

        create!(match: match, recipient: contact, decision_id_for_delivery: decision_id)
      end
    end

    def event_label
      'Initial contacts notified of manual match'
    end
  end
end
