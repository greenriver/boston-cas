module Notifications
  class MatchRecommendationDndStaff < Base
    def self.create_for_match!(match)
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.match_recommendation_dnd_staff_decision
    end

    def event_label
      "#{_('DND')} notified of new match"
    end

    def contacts_editable?
      true
    end
  end
end
