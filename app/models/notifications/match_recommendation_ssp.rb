module Notifications
  class MatchRecommendationSsp < Base

    def self.create_for_match! match
      match.ssp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_('Stabilization Service Provider')} notified of potential match (no client details sent)"
    end
    
    def show_client_info?
      false
    end    
  end
end
