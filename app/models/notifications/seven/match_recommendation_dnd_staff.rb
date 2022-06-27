###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Seven
  class MatchRecommendationDndStaff < Notifications::MatchRecommendationDndStaff
    def decision
      match.seven_match_recommendation_dnd_staff_decision
    end
  end
end
