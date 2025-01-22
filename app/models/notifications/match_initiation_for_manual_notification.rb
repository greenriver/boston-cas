###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class MatchInitiationForManualNotification < Notifications::Base
    def self.create_for_match! match
      match.send(match.match_route.initial_contacts_for_match).each do |contact|
        # this notification includes a link to the un-started matches, don't send anything
        # if the user can't access the link
        user = contact.user
        next unless user&.can_see_alternate_matches? || user&.can_see_all_alternate_matches?

        create! match: match, recipient: contact
      end
    end

    def event_label
      'Initial contacts notified of manual match'
    end
  end
end
