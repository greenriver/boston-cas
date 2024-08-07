###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteThirteenDecisions
  extend ActiveSupport::Concern

  included do
    has_decision :thirteen_client_match, decision_class_name: 'MatchDecisions::Thirteen::ThirteenClientMatch', notification_class_name: 'Notifications::Thirteen::ThirteenClientMatch'
    has_decision :thirteen_match_acknowledgement, decision_class_name: 'MatchDecisions::Thirteen::ThirteenMatchAcknowledgement', notification_class_name: 'Notifications::Thirteen::ThirteenMatchAcknowledgementShelterAgency'
    has_decision :thirteen_client_review, decision_class_name: 'MatchDecisions::Thirteen::ThirteenClientReview', notification_class_name: 'Notifications::Thirteen::ThirteenClientReviewShelterAgency'
    has_decision :thirteen_client_review_decline, decision_class_name: 'MatchDecisions::Thirteen::ThirteenClientReviewDecline', notification_class_name: 'Notifications::Thirteen::ThirteenClientReviewDecline'
    has_decision :thirteen_hearing_scheduled, decision_class_name: 'MatchDecisions::Thirteen::ThirteenHearingScheduled', notification_class_name: 'Notifications::Thirteen::ThirteenHearingScheduledHsa'
    has_decision :thirteen_hearing_scheduled_decline, decision_class_name: 'MatchDecisions::Thirteen::ThirteenHearingScheduledDecline', notification_class_name: 'Notifications::Thirteen::ThirteenHearingScheduledDecline'
    has_decision :thirteen_hearing_outcome, decision_class_name: 'MatchDecisions::Thirteen::ThirteenHearingOutcome', notification_class_name: 'Notifications::Thirteen::ThirteenHearingOutcomeHsa'
    has_decision :thirteen_hearing_outcome_decline, decision_class_name: 'MatchDecisions::Thirteen::ThirteenHearingOutcomeDecline', notification_class_name: 'Notifications::Thirteen::ThirteenHearingOutcomeDecline'
    has_decision :thirteen_hsa_review, decision_class_name: 'MatchDecisions::Thirteen::ThirteenHsaReview', notification_class_name: 'Notifications::Thirteen::ThirteenHsaReviewHsa'
    has_decision :thirteen_hsa_review_decline, decision_class_name: 'MatchDecisions::Thirteen::ThirteenHsaReviewDecline', notification_class_name: 'Notifications::Thirteen::ThirteenHsaReviewDecline'
    has_decision :thirteen_accept_referral, decision_class_name: 'MatchDecisions::Thirteen::ThirteenAcceptReferral', notification_class_name: 'Notifications::Thirteen::ThirteenAcceptReferralHsa'
    has_decision :thirteen_accept_referral_decline, decision_class_name: 'MatchDecisions::Thirteen::ThirteenAcceptReferralDecline', notification_class_name: 'Notifications::Thirteen::ThirteenAcceptReferralDecline'
    has_decision :thirteen_confirm_match_success, decision_class_name: 'MatchDecisions::Thirteen::ThirteenConfirmMatchSuccess', notification_class_name: 'Notifications::Thirteen::ThirteenConfirmMatchSuccessDndStaff'
  end
end
