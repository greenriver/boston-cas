###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Eight
  class EightMatchRecommendation < Notifications::MatchRecommendationDndStaff
    def decision
      match.eight_match_recommendation_decision
    end
  end
end
