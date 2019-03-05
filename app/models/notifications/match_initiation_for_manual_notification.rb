module Notifications
  class MatchInitiationForManualNotification < Notifications::Base

    def self.create_for_match! match
      match.send(match.match_route.initial_contacts_for_match).each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "Initial contacts notified of manual match"
    end
  end
end