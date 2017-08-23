module Notifications
  class MatchRecommendationShelterAgency < Base
    
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end
    
    def decision
      match.match_recommendation_shelter_agency_decision
    end

    def event_label
      "#{_('Shelter Agency')} notified of new match"
    end

    def should_expire?
      true
    end

  end
end
