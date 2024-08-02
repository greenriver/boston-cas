###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Thirteen < Base
    def title
      Translation.translate('Match Route Thirteen')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end

    def self.match_steps
      {
        'MatchDecisions::Thirteen::ClientMatch' => 1,
        'MatchDecisions::Thirteen::MatchAcknowledgement' => 2,
        'MatchDecisions::Thirteen::ClientReview' => 3,
        'MatchDecisions::Thirteen::HearingScheduled' => 4,
        'MatchDecisions::Thirteen::HearingOutcome' => 5,
        'MatchDecisions::Thirteen::HsaReview' => 6,
        'MatchDecisions::Thirteen::AcceptReferral' => 7,
        'MatchDecisions::Thirteen::ConfirmMatchSuccess' => 8,
      }
    end

    def self.match_steps_for_reporting
      {
        'MatchDecisions::Thirteen::ClientMatch' => 1,
        'MatchDecisions::Thirteen::MatchAcknowledgement' => 2,
        'MatchDecisions::Thirteen::ClientReview' => 3,
        'MatchDecisions::Thirteen::ClientReviewDecline' => 4,
        'MatchDecisions::Thirteen::HearingScheduled' => 5,
        'MatchDecisions::Thirteen::HearingScheduledDecline' => 6,
        'MatchDecisions::Thirteen::HearingOutcome' => 7,
        'MatchDecisions::Thirteen::HearingOutcomeDecline' => 8,
        'MatchDecisions::Thirteen::HsaReview' => 9,
        'MatchDecisions::Thirteen::HsaReviewDecline' => 10,
        'MatchDecisions::Thirteen::AcceptReferral' => 11,
        'MatchDecisions::Thirteen::AcceptReferralDecline' => 12,
        'MatchDecisions::Thirteen::ConfirmMatchSuccess' => 13,
      }
    end

    def required_contact_types
      [
        'shelter_agency_contacts',
        'housing_subsidy_admin_contacts',
        'ssp_contacts',
        'hsp_contacts',
        'dnd_staff_contacts',
      ]
    end

    def contact_label_for(contact_type)
      case contact_type
      when :shelter_agency_contacts
        Translation.translate('Shelter Agency Thirteen')
      when :housing_subsidy_admin_contacts
        Translation.translate('HSA Thirteen')
      when :ssp_contacts
        Translation.translate('SSP Thirteen')
      when :hsp_contacts
        Translation.translate('HSP Thirteen')
      when :dnd_staff_contacts
        Translation.translate('CoC Thirteen')
      else
        super
      end
    end

    def initial_decision
      :thirteen_client_match_decision
    end

    def success_decision
      :thirteen_confirm_match_success
    end

    def initial_contacts_for_match
      :dnd_staff_contacts
    end

    def status_declined?(match)
      [
        match.thirteen_client_review_decision&.status == 'declined' &&
          match.thirteen_client_review_decision_dnd_staff_decision&.status != 'decline_overridden',
        match.thirteen_hearing_scheduled_decision&.status == 'declined' &&
          match.thirteen_hearing_scheduled_decision_dnd_staff_decision&.status != 'decline_overridden',
        match.thirteen_hearing_outcome_decision&.status == 'declined' &&
          match.thirteen_hearing_outcome_decision_dnd_staff_decision&.status != 'decline_overridden',
        match.thirteen_hsa_review_decision&.status == 'declined' &&
          match.thirteen_hsa_review_decision_dnd_staff_decision&.status != 'decline_overridden',
        match.thirteen_accept_referral_decision&.status == 'declined' &&
          match.thirteen_accept_referral_decision_dnd_staff_decision&.status != 'decline_overridden',
      ].any?
    end
  end
end
