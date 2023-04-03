###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

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

  end
end
