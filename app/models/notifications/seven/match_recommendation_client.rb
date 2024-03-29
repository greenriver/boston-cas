###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Seven
  class MatchRecommendationClient < ::Notifications::MatchRecommendationClient
    def decision
      match.seven_approve_match_housing_subsidy_admin_decision
    end
  end
end
