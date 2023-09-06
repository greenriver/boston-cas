###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteTenDecisions
  extend ActiveSupport::Concern

  included do
    has_decision :ten_match_recommendation, decision_class_name: 'MatchDecisions::Ten::TenMatchRecommendation', notification_class_name: 'Notifications::Ten::TenMatchRecommendation'
    has_decision :ten_confirm_match_success, decision_class_name: 'MatchDecisions::Ten::TenConfirmMatchSuccess', notification_class_name: 'Notifications::Ten::TenConfirmMatchSuccess'
  end
end
