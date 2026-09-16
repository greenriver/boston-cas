###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module RouteFourteenDecisions
  extend ActiveSupport::Concern

  included do
    has_decision :fourteen_initiate_match, decision_class_name: 'MatchDecisions::Fourteen::FourteenInitiateMatch', notification_class_name: 'Notifications::Fourteen::FourteenInitiateMatchDndStaff'
    has_decision :fourteen_match_acknowledgement, decision_class_name: 'MatchDecisions::Fourteen::FourteenMatchAcknowledgement', notification_class_name: 'Notifications::Fourteen::FourteenMatchAcknowledgementShelterAgency'
    has_decision :fourteen_match_acknowledgement_decline, decision_class_name: 'MatchDecisions::Fourteen::FourteenMatchAcknowledgementDecline', notification_class_name: 'Notifications::Fourteen::FourteenMatchAcknowledgementDecline'
    has_decision :fourteen_client_review, decision_class_name: 'MatchDecisions::Fourteen::FourteenClientReview', notification_class_name: 'Notifications::Fourteen::FourteenClientReviewShelterAgency'
    has_decision :fourteen_client_review_decline, decision_class_name: 'MatchDecisions::Fourteen::FourteenClientReviewDecline', notification_class_name: 'Notifications::Fourteen::FourteenClientReviewDecline'
    has_decision :fourteen_eligibility_screening, decision_class_name: 'MatchDecisions::Fourteen::FourteenEligibilityScreening', notification_class_name: 'Notifications::Fourteen::FourteenEligibilityScreeningHsp'
    has_decision :fourteen_eligibility_screening_decline, decision_class_name: 'MatchDecisions::Fourteen::FourteenEligibilityScreeningDecline', notification_class_name: 'Notifications::Fourteen::FourteenEligibilityScreeningDecline'
    has_decision :fourteen_subsidy_admin_screening, decision_class_name: 'MatchDecisions::Fourteen::FourteenSubsidyAdminScreening', notification_class_name: 'Notifications::Fourteen::FourteenSubsidyAdminScreeningHsa'
    has_decision :fourteen_subsidy_admin_screening_decline, decision_class_name: 'MatchDecisions::Fourteen::FourteenSubsidyAdminScreeningDecline', notification_class_name: 'Notifications::Fourteen::FourteenSubsidyAdminScreeningDecline'
    has_decision :fourteen_offer_unit, decision_class_name: 'MatchDecisions::Fourteen::FourteenOfferUnit', notification_class_name: 'Notifications::Fourteen::FourteenOfferUnitHsp'
    has_decision :fourteen_offer_unit_decline, decision_class_name: 'MatchDecisions::Fourteen::FourteenOfferUnitDecline', notification_class_name: 'Notifications::Fourteen::FourteenOfferUnitDecline'
    has_decision :fourteen_confirm_match_success, decision_class_name: 'MatchDecisions::Fourteen::FourteenConfirmMatchSuccess', notification_class_name: 'Notifications::Fourteen::FourteenConfirmMatchSuccessDndStaff'
  end
end
