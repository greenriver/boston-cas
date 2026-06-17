###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Seven
  class MatchRecommendationClient < ::Notifications::MatchRecommendationClient
    def decision
      match.seven_approve_match_housing_subsidy_admin_decision
    end
  end
end
