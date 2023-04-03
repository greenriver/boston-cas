###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Nine
  class NineMatchRecommendation < Notifications::MatchRecommendationDndStaff
    def decision
      match.nine_match_recommendation_decision
    end
  end
end
