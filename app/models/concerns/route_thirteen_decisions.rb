###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteThirteenDecisions
  extend ActiveSupport::Concern

  included do
    has_decision :thirteen_client_match, decision_class_name: 'MatchDecisions::Thirteen::ClientMatch', notification_class_name: 'Notifications::Thirteen::ClientMatch'
    has_decision :thirteen_match_acknowledgement, decision_class_name: 'MatchDecisions::Thirteen::MatchAcknowledgement', notification_class_name: 'Notifications::Thirteen::MatchAcknowledgementShelterAgency'
    has_decision :thirteen_client_review, decision_class_name: 'MatchDecisions::Thirteen::ClientReview', notification_class_name: 'Notifications::Thirteen::ClientReviewShelterAgency'
    has_decision :thirteen_client_review_decline, decision_class_name: 'MatchDecisions::Thirteen::ClientReviewDecline', notification_class_name: 'Notifications::Thirteen::ClientReviewDecline'
    has_decision :thirteen_hearing_scheduled, decision_class_name: 'MatchDecisions::Thirteen::HearingScheduled', notification_class_name: 'Notifications::Thirteen::HearingScheduledHsa'
    has_decision :thirteen_hearing_scheduled_decline, decision_class_name: 'MatchDecisions::Thirteen::HearingScheduledDecline', notification_class_name: 'Notifications::Thirteen::HearingScheduledDecline'
    has_decision :thirteen_hearing_outcome, decision_class_name: 'MatchDecisions::Thirteen::HearingOutcome', notification_class_name: 'Notifications::Thirteen::HearingOutcomeHsa'
    has_decision :thirteen_hearing_outcome_decline, decision_class_name: 'MatchDecisions::Thirteen::HearingOutcomeDecline', notification_class_name: 'Notifications::Thirteen::HearingOutcomeDecline'
    has_decision :thirteen_hsa_review, decision_class_name: 'MatchDecisions::Thirteen::HsaReview', notification_class_name: 'Notifications::Thirteen::HsaReviewHsa'
    has_decision :thirteen_hsa_review_decline, decision_class_name: 'MatchDecisions::Thirteen::HsaReviewDecline', notification_class_name: 'Notifications::Thirteen::HsaReviewDecline'
    has_decision :thirteen_accept_referral, decision_class_name: 'MatchDecisions::Thirteen::AcceptReferral', notification_class_name: 'Notifications::Thirteen::AcceptReferralHsa'
    has_decision :thirteen_accept_referral_decline, decision_class_name: 'MatchDecisions::Thirteen::AcceptReferralDecline', notification_class_name: 'Notifications::Thirteen::AcceptReferralDecline'
    has_decision :thirteen_confirm_match_success, decision_class_name: 'MatchDecisions::Thirteen::ConfirmMatchSuccess', notification_class_name: 'Notifications::Thirteen::ConfirmMatchSuccessDndStaff'
  end
end
