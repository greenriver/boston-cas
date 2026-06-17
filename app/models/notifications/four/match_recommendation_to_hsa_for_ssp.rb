###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Four
  class MatchRecommendationToHsaForSsp < Notifications::MatchRecommendationSsp
    def decision
      match.four_match_recommendation_shelter_agency_decision
    end
  end
end
