###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class MatchRecommendationShelterAgency < Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def decision
      match.match_recommendation_shelter_agency_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency')} notified of new match"
    end
  end
end
