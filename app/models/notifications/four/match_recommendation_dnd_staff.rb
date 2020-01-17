###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Notifications::Four
  class MatchRecommendationDndStaff < Notifications::MatchRecommendationDndStaff

    def decision
      match.four_match_recommendation_dnd_staff_decision
    end

  end
end
