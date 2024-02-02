###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteFourDecisions
  extend ActiveSupport::Concern

  included do
    has_decision :four_match_recommendation_dnd_staff, decision_class_name: 'MatchDecisions::Four::MatchRecommendationDndStaff', notification_class_name: 'Notifications::Four::MatchRecommendationDndStaff'
    has_decision :four_match_recommendation_shelter_agency, decision_class_name: 'MatchDecisions::Four::MatchRecommendationShelterAgency', notification_class_name: 'Notifications::Four::MatchRecommendationShelterAgency'
    has_decision :four_confirm_shelter_agency_decline_dnd_staff, decision_class_name: 'MatchDecisions::Four::ConfirmShelterAgencyDeclineDndStaff', notification_class_name: 'Notifications::Four::ConfirmShelterAgencyDeclineDndStaff'
    has_decision :four_match_recommendation_hsa, decision_class_name: 'MatchDecisions::Four::MatchRecommendationHsa', notification_class_name: 'Notifications::Four::MatchRecommendationHsa'
    has_decision :four_confirm_hsa_initial_decline_dnd_staff, decision_class_name: 'MatchDecisions::Four::ConfirmHsaInitialDeclineDndStaff', notification_class_name: 'Notifications::Four::ConfirmHsaInitialDeclineDndStaff'
    has_decision :four_schedule_criminal_hearing_housing_subsidy_admin, decision_class_name: 'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin', notification_class_name: 'Notifications::Four::ScheduleCriminalHearingHousingSubsidyAdmin'
    has_decision :four_approve_match_housing_subsidy_admin, decision_class_name: 'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin', notification_class_name: 'Notifications::Four::CriminalHearingScheduledClient'
    has_decision :four_confirm_housing_subsidy_admin_decline_dnd_staff, decision_class_name: 'MatchDecisions::Four::ConfirmHousingSubsidyAdminDeclineDndStaff', notification_class_name: 'Notifications::Four::ConfirmHousingSubsidyAdminDeclineDndStaff'
    has_decision :four_record_client_housed_date_housing_subsidy_administrator, decision_class_name: 'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator', notification_class_name: 'Notifications::Four::HousingSubsidyAdminDecisionClient'
    has_decision :four_confirm_match_success_dnd_staff, decision_class_name: 'MatchDecisions::Four::ConfirmMatchSuccessDndStaff', notification_class_name: 'Notifications::Four::ConfirmMatchSuccessDndStaff'
  end
end
