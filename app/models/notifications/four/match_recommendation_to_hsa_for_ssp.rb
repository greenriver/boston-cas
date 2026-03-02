###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Four
  class MatchRecommendationToHsaForSsp < Notifications::MatchRecommendationSsp
    def decision
      match.four_match_recommendation_shelter_agency_decision
    end
  end
end
