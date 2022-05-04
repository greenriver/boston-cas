###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Six
  class MatchRecommendationDndStaff < Notifications::MatchRecommendationDndStaff
    def decision
      match.six_match_recommendation_dnd_staff_decision
    end
  end
end
