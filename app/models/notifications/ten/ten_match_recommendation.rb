###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Ten
  class TenMatchRecommendation < Notifications::MatchRecommendationDndStaff
    def decision
      match.ten_match_recommendation_decision
    end
  end
end
