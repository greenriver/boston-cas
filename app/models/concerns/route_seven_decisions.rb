###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteSevenDecisions
  extend ActiveSupport::Concern

  included do
    has_decision :seven_match_recommendation_dnd_staff, decision_class_name: 'MatchDecisions::Seven::MatchRecommendationDndStaff', notification_class_name: 'Notifications::Seven::MatchRecommendationDndStaff'
    has_decision :seven_approve_match_housing_subsidy_admin, decision_class_name: 'MatchDecisions::Seven::ApproveMatchHousingSubsidyAdmin', notification_class_name: 'Notifications::Seven::ApproveMatchHousingSubsidyAdmin'
    has_decision :seven_confirm_housing_subsidy_admin_decline_dnd_staff, decision_class_name: 'MatchDecisions::Seven::ConfirmHousingSubsidyAdminDeclineDndStaff', notification_class_name: 'Notifications::Seven::ConfirmHsaDeclineDndStaff'
    has_decision :seven_confirm_match_success_dnd_staff, decision_class_name: 'MatchDecisions::Seven::ConfirmMatchSuccessDndStaff', notification_class_name: 'Notifications::Seven::ConfirmMatchSuccessDndStaff'
  end
end
