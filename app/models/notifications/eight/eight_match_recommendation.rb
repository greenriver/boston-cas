###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Eight
  class EightMatchRecommendation < Notifications::MatchRecommendationDndStaff
    def decision
      match.eight_match_recommendation_decision
    end
  end
end
