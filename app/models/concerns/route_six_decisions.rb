###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteSixDecisions
  extend ActiveSupport::Concern

  included do
    has_decision :six_match_recommendation_dnd_staff, decision_class_name: 'MatchDecisions::Six::MatchRecommendationDndStaff', notification_class_name: 'Notifications::Six::MatchRecommendationDndStaff'
    has_decision :six_match_recommendation_shelter_agency, decision_class_name: 'MatchDecisions::Six::MatchRecommendationShelterAgency', notification_class_name: 'Notifications::Six::MatchRecommendationShelterAgency'
    has_decision :six_confirm_shelter_agency_decline_dnd_staff, decision_class_name: 'MatchDecisions::Six::ConfirmShelterAgencyDeclineDndStaff', notification_class_name: 'Notifications::Six::ConfirmShelterAgencyDeclineDndStaff'
    has_decision :six_approve_match_housing_subsidy_admin, decision_class_name: 'MatchDecisions::Six::ApproveMatchHousingSubsidyAdmin', notification_class_name: 'Notifications::Six::ApproveMatchHousingSubsidyAdmin'
    has_decision :six_confirm_housing_subsidy_admin_decline_dnd_staff, decision_class_name: 'MatchDecisions::Six::ConfirmHousingSubsidyAdminDeclineDndStaff', notification_class_name: 'Notifications::Six::ConfirmHsaDeclineDndStaff'
    has_decision :six_confirm_match_success_dnd_staff, decision_class_name: 'MatchDecisions::Six::ConfirmMatchSuccessDndStaff', notification_class_name: 'Notifications::Six::ConfirmMatchSuccessDndStaff'
  end
end
