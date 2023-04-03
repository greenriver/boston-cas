###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Four
  class MatchRecommendationSsp < Notifications::MatchRecommendationSsp

    def decision
      match.four_match_recommendation_hsa_decision
    end

  end
end
