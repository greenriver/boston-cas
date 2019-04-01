module Notifications
  class MatchRecommendationClient < Base
    def self.create_for_match!(match)
      match.client_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      'Client notified of potential match'
    end
  end
end
