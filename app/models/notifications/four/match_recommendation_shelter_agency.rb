###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Four
  class MatchRecommendationShelterAgency < ::Notifications::MatchRecommendationShelterAgency

    def decision
      match.four_match_recommendation_shelter_agency_decision
    end

  end
end
