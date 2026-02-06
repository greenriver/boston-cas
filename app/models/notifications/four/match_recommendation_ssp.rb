###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Four
  class MatchRecommendationSsp < Notifications::MatchRecommendationSsp
    def decision
      match.four_match_recommendation_hsa_decision
    end
  end
end
